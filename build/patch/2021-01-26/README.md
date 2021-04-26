Updates older image versions to resolve the following

Debian/Ubuntu packages:
- libcurl3-gnutls https://lists.debian.org/debian-lts-announce/2020/12/msg00029.html
- libcairo-gobject2, libcairo2 https://lists.debian.org/debian-lts-announce/2021/01/msg00006.html
- https://lists.debian.org/debian-lts-announce/2020/12/msg00033.html
- openjdk-8-jdk, openjdk-8-jdk-headless, openjdk-8-jre, openjdk-8-jre-headless https://lists.debian.org/debian-lts-announce/2020/12/msg00033.html
- libflac8 https://lists.debian.org/debian-lts-announce/2021/01/msg00002.htm
- libssl1.1 https://lists.debian.org/debian-security-announce/2020/msg00214.html
- libp11-kit0, libp11-kit-dev https://lists.debian.org/debian-security-announce/2021/msg00000.html
- apt-transport-https, libapt-inst2.0, libapt-pkg5.0 https://lists.debian.org/debian-security-announce/2020/msg00215.html
- firefox-esr https://lists.debian.org/debian-security-announce/2020/msg00006.html
- libproxy1v5 https://lists.ubuntu.com/archives/ubuntu-security-announce/2021-January/005813.html

Excluded due to false positive or marked as low risk / unimportant / ignored w/no fix available:
- docker-engine http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-13401 (False positive, only CLI present, and already patched in 3.0.12+azure and up)
