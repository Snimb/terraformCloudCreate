### ALERTS FOR POSTGRESQL DATABASE ###
resource "azurerm_monitor_metric_alert" "postgresql_metric_alert" {
  for_each = local.postgresql_metric_alerts

  name                = "${each.key}-alert"
  resource_group_name = azurerm_resource_group.diag.name
  scopes              = [var.module_postgres_fs_id]
  description         = each.value.description

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }

  severity                 = 3
  auto_mitigate            = true
  enabled                  = true
  frequency                = each.value.frequency
  window_size              = each.value.window_size
  target_resource_location = var.location
}

resource "azurerm_monitor_activity_log_alert" "psql_log_alert" {
  for_each = local.alert_criteria

  name                = "${each.key}-activity-alert"
  resource_group_name = azurerm_resource_group.diag.name
  scopes              = [var.module_postgres_fs_id]
  description         = "Alert for ${each.key} on PostgreSQL Flexible Server."

  criteria {
    category       = each.value.category
    operation_name = lookup(each.value, "operation_name", null)
    resource_id    = var.module_postgres_fs_id
    resource_type  = "Microsoft.DBforPostgreSQL/flexibleServers"
    level          = lookup(each.value, "level", null)

  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "dynamic_alerts" {
  for_each = { for idx, rule in local.alert_rules : idx => rule }

  name                = each.value.name
  resource_group_name = azurerm_resource_group.diag.name
  location            = azurerm_resource_group.diag.location

  evaluation_frequency = each.value.frequency
  window_duration      = each.value.window
  scopes               = [azurerm_log_analytics_workspace.workspace.id]
  severity             = each.value.severity
  criteria {
    query                   = each.value.query
    time_aggregation_method = "Maximum"
    threshold               = each.value.threshold
    operator                = each.value.operator
    metric_measure_column   = each.value.metricmeasure
    failing_periods {
      minimum_failing_periods_to_trigger_alert = each.value.periods
      number_of_evaluation_periods             = each.value.evaluation
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }

  enabled      = true
  description  = each.value.description
  display_name = each.value.display_name
}


