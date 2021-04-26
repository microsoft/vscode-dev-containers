Updates older image versions to resolve the following

Debian/Ubuntu packages:
- libproxy1v5 https://lists.ubuntu.com/archives/ubuntu-security-announce/2021-January/005813.htm
- cairo http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-35492
- firefox-esr http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-16044
- openjdk-8 https://security-tracker.debian.org/tracker/DLA-2412-2
- p11-kit http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-29361
- p11-kit http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-29362
- curl http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-8284
- curl http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-8285
- curl http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-8286
- apt http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-27350
- openssl http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-1971

Go:
- http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-29510
- http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-29509
- http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-29511

Excluded due to false positive or marked as low risk / unimportant / ignored w/no fix available:
- openssl https://ubuntu.com/security/CVE-2020-14145 (low priority, no fix)
- openssl https://security-tracker.debian.org/tracker/CVE-2020-14145 (marked unimportant, no fix)
- openssl https://ubuntu.com/security/CVE-2020-15778 (low priority, no fix)
- openssl https://security-tracker.debian.org/tracker/CVE-2020-15778 (marked unimportant, no fix)
- docker-engine http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-13401 (False positive, only CLI present, and already patched in 3.0.12+azure and up)
