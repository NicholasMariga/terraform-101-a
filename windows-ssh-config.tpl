add-content -path c:/Users/Turnkey/.ssh/config -value @'
Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@