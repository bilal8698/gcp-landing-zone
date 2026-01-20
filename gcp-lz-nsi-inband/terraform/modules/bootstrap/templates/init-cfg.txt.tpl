type=static
hostname=${hostname}
%{ if panorama_server != "" ~}
panorama-server=${panorama_server}
%{ endif ~}
%{ if panorama_server2 != "" ~}
panorama-server-2=${panorama_server2}
%{ endif ~}
%{ if tplname != "" ~}
tplname=${tplname}
%{ endif ~}
%{ if dgname != "" ~}
dgname=${dgname}
%{ endif ~}
%{ if vm_auth_key != "" ~}
vm-auth-key=${vm_auth_key}
%{ endif ~}
%{ if op_command_modes != "" ~}
op-command-modes=${op_command_modes}
%{ endif ~}
dns-primary=${dns_primary}
dns-secondary=${dns_secondary}
ntp-primary=${ntp_primary}
ntp-secondary=${ntp_secondary}
timezone=${timezone}
%{ if login_banner != "" ~}
login-banner=${login_banner}
%{ endif ~}
%{ if vm_series_auto_reg != "" ~}
vm-series-auto-registration-pin-id=${vm_series_auto_reg}
vm-series-auto-registration-pin-value=${vm_auth_key}
%{ endif ~}
