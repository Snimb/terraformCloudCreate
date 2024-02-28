output "key_vault_id" {
  value = azurerm_key_vault.kv.id
  description = "Key Vault ID"
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
  description = "Key Vault URI"
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
  description = "The name of the Key Vault."
}
output "key_vault_object" {
  value       = azurerm_key_vault.kv
  description = "The entire Key Vault object."
}
/*
 output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.default.id
 }

 output "user_assigned_identity_client_id" {
  value =  azurerm_user_assigned_identity.default.client_id
 }
*/
output "postgres_password_secret_id" {
  value = azurerm_key_vault_secret.postgres_password.id
  description = "The ID of the Key Vault secret containing the Postgres database password."
}

output "postgres_hostname_secret_id" {
  value = azurerm_key_vault_secret.postgres_hostname.id
  description = "The ID of the Key Vault secret containing the Postgres database hostname."
}

output "db_connection_strings_secret_ids" {
  value = { for k, secret in azurerm_key_vault_secret.db_connection_strings : k => secret.id }
  description = "A map of database names to the IDs of the Key Vault secrets containing their connection strings."
}

output "postgres_password_secret_name" {
  value = azurerm_key_vault_secret.postgres_password.name
  description = "The name of the Key Vault secret containing the Postgres database password."
}

output "postgres_hostname_secret_name" {
  value = azurerm_key_vault_secret.postgres_hostname.name
  description = "The name of the Key Vault secret containing the Postgres database hostname."
}

output "db_connection_strings_secret_names" {
  value = [for secret in values(azurerm_key_vault_secret.db_connection_strings) : secret.name]
  description = "A list of the names of the Key Vault secrets containing database connection strings."
}
