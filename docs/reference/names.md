
The following Zeek logs and fields can be used to associate an IP address with a hostname.

| Log        | Domain or Hostname                                    | IP Address                     |
|:----------:| -----------------------------------------------------:|:------------------------------ |
| [dns]      | `query`                                               | `answers`                      |
| [http]     | `host`                                                | `id.resp_h`                    |
| [ssl]      | `server_name`                                         | `id.resp_h`                    |
| [dhcp]     | `host_name`, `domain`, `client_fqdn`                  | `assigned_addr`, `client_addr` |
| [kerberos] | `client`                                              | `id.orig_h`                    |
| [ntlm]     | `hostname`                                            | `id.orig_h`                    |
| [ntlm]     | `server_dns_computer_name`, `server_nb_computer_name` | `id.resp_h`                    |


[dns]: https://docs.zeek.org/en/master/scripts/base/protocols/dns/main.zeek.html#type-DNS::Info
[http]: https://docs.zeek.org/en/master/scripts/base/protocols/http/main.zeek.html#type-HTTP::Info
[ssl]: https://docs.zeek.org/en/master/scripts/base/protocols/ssl/main.zeek.html#type-SSL::Info
[dhcp]: https://docs.zeek.org/en/master/scripts/base/protocols/dhcp/main.zeek.html#type-DHCP::Info
[kerberos]: https://docs.zeek.org/en/master/scripts/base/protocols/krb/main.zeek.html#type-KRB::Info
[ntlm]: https://docs.zeek.org/en/master/scripts/base/protocols/ntlm/main.zeek.html#type-NTLM::Info