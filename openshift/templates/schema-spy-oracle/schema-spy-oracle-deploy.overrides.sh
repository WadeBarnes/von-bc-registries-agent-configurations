.  $(find . -name overrides.inc)
# ========================================================================
# Special Deployment Parameters needed for the SchemaSpy instance.
# ------------------------------------------------------------------------
# The results need to be encoded as OpenShift template
# parameters for use with oc process.
#
# The generated config map is used to update the Caddy configuration
# ========================================================================
CONFIG_MAP_NAME=schema-spy-oracle-caddy-conf-indy-cat
SOURCE_FILE=$( dirname "$0" )/Caddyfile
OUTPUT_FORMAT=json
OUTPUT_FILE=${CONFIG_MAP_NAME}-configmap_DeploymentConfig.json

printStatusMsg "Generating ConfigMap; ${CONFIG_MAP_NAME} ..."
generateConfigMap "${CONFIG_MAP_NAME}" "${SOURCE_FILE}" "${OUTPUT_FORMAT}" "${OUTPUT_FILE}"

if createOperation; then
  # Randomly generate a set of credentials without asking ...
  printStatusMsg "Creating a set of random user credentials ..."
  writeParameter "SCHEMASPY_USER" $(generateUsername) "false"
  writeParameter "SCHEMASPY_PASSWORD" $(generatePassword) "false"
else
  # Secrets are removed from the configurations during update operations ...
  printStatusMsg "Update operation detected ...\nSkipping the generation of random user credentials ...\n"
  writeParameter "SCHEMASPY_USER" "generation_skipped" "false"
  writeParameter "SCHEMASPY_PASSWORD" "generation_skipped" "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}