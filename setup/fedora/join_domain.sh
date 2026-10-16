#! /bin/bash

# Setup Fedora system on UW-Madison domain
# https://kb.wisc.edu/124525

# Download required sources
dnf -y install realmd sssd oddjob oddjob-mkhomedir adcli samba-common-tools krb5-workstation

# Set the NTP server
sed -i 's/#NTP=/NTP=ntp1.doit.wisc.edu/g' /etc/systemd/timesyncd.conf;
sed -i 's/#FallbackNTP=.*/FallbackNTP=ntp2.doit.wisc.edu doit3.doit.wisc.edu/g' /etc/systemd/timesyncd.conf;
timedatectl set-timezone America/Chicago
systemctl restart systemd-timesyncd

# Discover the domain
realm discover AD.WISC.EDU

# Prompt for username to join the domain. This must not be in the format of AD\ OR @ad.wisc.edu
while :
do
    read -r -p "OU Account: " CAD_OU_ACCOUNT;
    if [[ ! "$CAD_OU_ACCOUNT" =~ (\\|@ad\.wisc\.edu$) ]]; then
        break;
    else
        echo "Username is incorrect. Try again."
    fi
done

# Join the domain
realm join AD.WISC.EDU -U $CAD_OU_ACCOUNT --computer-ou=OU=Computers,OU=WSB,OU=orgUnits,DC=ad,DC=wisc,DC=edu;

# Configure SSSD
cat <<EOF > /etc/sssd/conf.d/ad.wisc.edu.conf
[sssd]
domains = ad.wisc.edu
config_file_version = 2
services = nss, pam

[domain/ad.wisc.edu]
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = AD.WISC.EDU
realmd_tags = manages-system joined-with-adcli
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = ad.wisc.edu
use_fully_qualified_names = True
ldap_id_mapping = True
ldap_referrals = False
access_provider = ad
ad_gpo_access_control = permissive
EOF

chmod 600 /etc/sssd/conf.d/*;
systemctl restart sssd;

# Configure Kerberos
mkdir /etc/krb5.conf.d 2> /dev/null
cat <<EOF > /etc/krb5.conf.d/ad.wisc.edu.conf
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
dns_lookup_realm = true
dns_lookup_kdc = true
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns = false
default_realm = AD.WISC.EDU
udp_preference_limit = 0
default_ccache_name = KEYRING:persistent:%{uid}

[realms]
AD.WISC.EDU = {
kdc = AD.WISC.EDU
admin_server = AD.WISC.EDU
}

[domain_realm]
.ad.wisc.edu = AD.WISC.EDU
ad.wisc.edu = AD.WISC.EDU
EOF

# Configure PAM
authselect select sssd with-mkhomedir
systemctl enable --now oddjobd.service

echo "Restart your computer to complete the domain join process"