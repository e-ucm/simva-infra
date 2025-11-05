$simvaenvFile="..\docker-stacks\etc\simva.d\simva-env.sh"
$content = (Get-Content $simvaenvFile)
$content -replace '^export SIMVA_ENVIRONMENT=".*"', "export SIMVA_ENVIRONMENT=`"development`"" | Set-Content $simvaenvFile

$simvadevenvFile="../docker-stacks/etc/simva.d/simva-env.dev.sh"
$content = (Get-Content $simvadevenvFile)
$content -replace '^export SIMVA_DEVELOPMENT_LOCAL=".*"', "export SIMVA_DEVELOPMENT_LOCAL=`"true`"" | Set-Content $simvadevenvFile
