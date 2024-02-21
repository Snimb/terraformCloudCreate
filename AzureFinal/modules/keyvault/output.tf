output "key_vault_id" {
  value = azurerm_key_vault.kv.id
  description = "Key Vault ID"
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
  description = "Key Vault URI"
}