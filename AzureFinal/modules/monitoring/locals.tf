locals {
  nsg_ids = {
    nsg-psql    = var.module_nsg_id_psql,
    nsg-jumpbox = var.module_nsg_id_jumpbox,
  }
}

locals {
  postgresql_metric_alerts = {
    cpu_usage_high = {
      metric_name = "cpu_percent"
      threshold   = 80
      description = "Alert when CPU usage exceeds 80% on PostgreSQL Server."
      frequency   = "PT1M"
      window_size = "PT5M"
      aggregation = "Average"
      operator    = "GreaterThan"
    },
    memory_usage_high = {
      metric_name = "memory_percent"
      threshold   = 80
      description = "Alert when Memory usage exceeds 80% on PostgreSQL Server."
      frequency   = "PT1M"
      window_size = "PT5M"
      aggregation = "Average"
      operator    = "GreaterThan"
    },
    cpu_usage_low = {
      metric_name = "cpu_percent"
      threshold   = 20
      description = "Alert when CPU usage falls below 20% on PostgreSQL Server."
      frequency   = "PT1M"
      window_size = "PT5M"
      aggregation = "Average"
      operator    = "LessThan"
    },
    memory_usage_low = {
      metric_name = "memory_percent"
      threshold   = 20
      description = "Alert when Memory usage falls below 20% on PostgreSQL Server."
      frequency   = "PT1M"
      window_size = "PT5M"
      aggregation = "Average"
      operator    = "LessThan"
    } ,storage_usage_high = {
      metric_name = "storage_percent"
      threshold   = 90
      description = "Alert when Storage usage exceeds 80% on PostgreSQL Server."
      frequency   = "PT1M"
      window_size = "PT5M"
      aggregation = "Average"
      operator    = "GreaterThan"
    },
    storage_usage_low = {
      metric_name = "storage_percent"
      threshold   = 20
      description = "Alert when Storage usage falls below 20% on PostgreSQL Server."
      frequency   = "PT1M"
      window_size = "PT5M"
      aggregation = "Average"
      operator    = "LessThan"
    },

    connection_count = {
      metric_name = "active_connections"
      threshold   = 150
      description = "Alert when connection count exceeds threshold on PostgreSQL Server."
      frequency   = "PT5M"
      window_size = "PT15M"
      aggregation = "Maximum"
      operator    = "GreaterThan"
    },
    io_consumption = {
      metric_name = "disk_iops_consumed_percentage"
      threshold   = 90
      description = "Alert when I/O consumption exceeds 90% on PostgreSQL Server."
      frequency   = "PT5M"
      window_size = "PT15M"
      aggregation = "Average"
      operator    = "GreaterThan"
    }
  }
}

locals {
  alert_criteria = {
    config_changes = {
      category       = "Administrative"
      operation_name = "Microsoft.DBforPostgreSQL/flexibleServers/configurations/write"
      description    = "Configuration changes on PostgreSQL server"
    },
    ha_state_changes = {
      category       = "Administrative"
      operation_name = "Microsoft.DBforPostgreSQL/flexibleServers/replicas/write"  # Adjusted, verify against real operations.
      description    = "High availability state changes in PostgreSQL server"
    },
    database_operations = {
      category       = "Administrative"
      operation_name = "Microsoft.DBforPostgreSQL/flexibleServers/databases/write"
      description    = "Database operations (create, update, delete) on PostgreSQL server"
    },
    admin_actions = {
      category       = "Administrative"
      operation_name = "Microsoft.DBforPostgreSQL/flexibleServers/write"
      description    = "Administrative operations on PostgreSQL server"
    },
    autoscale_events = {
      category    = "Autoscale"
      description = "Autoscale events affecting PostgreSQL server"
    },
    policy_changes = {
      category       = "Policy"
      operation_name = "Microsoft.Authorization/policyAssignments/write"
      description    = "Policy changes affecting resources, including PostgreSQL server"
    },
    recommendations = {
      category    = "Recommendation"
      description = "Azure recommendations for PostgreSQL server configurations"
    },
    resource_health = {
      category    = "ResourceHealth"
      description = "Health status changes of the PostgreSQL server"
    },
    security_incidents = {
      category       = "Security"
      operation_name = "Microsoft.Security/tasks/read"
      description    = "Security-related incidents affecting PostgreSQL server"
    },
    firewall_rule_changes = {
      category       = "Administrative"
      operation_name = "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/write"
      description    = "Firewall rule changes on PostgreSQL server"
    }
    # Add additional criteria as needed.
  }
}

locals {
  alert_rules = [
    {
      name          = "postgresql-failed-connections-alert"
      description   = "Alert triggered when there are too many failed connection attempts to the PostgreSQL database."
      display_name  = "Failed PostgreSQL Connection Attempts"
      query         = <<-EOT
AzureDiagnostics
| where ResourceType == 'POSTGRESQLSERVERS' and ResourceId contains '${var.module_postgres_fs_name}'
| where Category == 'PostgreSQLLogs'
| where Message has 'failed to authenticate'
| summarize FailedAttempts = count() by bin(TimeGenerated, 15m), '${var.module_postgres_fs_name}'
| where FailedAttempts > 5
  EOT
      severity      = 3
      frequency     = "PT5M"
      window        = "PT15M"
      threshold     = 5
      operator      = "GreaterThan"
      periods       = 1
      evaluation    = 1
      metricmeasure = "FailedAttempts"
    }
    ,
    {
      name          = "postgresql-long-running-queries"
      description   = "Alert triggered when long running PostgreSQL queries are detected."
      display_name  = "Long Running PostgreSQL Queries"
      query         = <<-EOT
AzureDiagnostics
| where Category == 'PostgreSQLLogs'
| where Message has 'duration:'
| extend query_duration = extract('duration: ([^ ]+)', 1, Message)
| where todouble(query_duration) > 30000
| summarize LongRunningQueries = count() by bin(TimeGenerated, 1h)
| where LongRunningQueries > 5
  EOT
      severity      = 3
      frequency     = "PT1H"
      window        = "PT1H"
      threshold     = 5
      operator      = "GreaterThan"
      periods       = 1
      evaluation    = 1
      metricmeasure = "LongRunningQueries"
    }
    ,
    {
      name          = "postgresql-deadlocks"
      description   = "Alert triggered when deadlocks are detected in PostgreSQL."
      display_name  = "PostgreSQL Deadlocks Detected"
      query         = <<-EOT
AzureDiagnostics
| where Message contains 'deadlock detected'
| summarize Deadlocks = count() by bin(TimeGenerated, 1h)
| where Deadlocks > 0
  EOT
      severity      = 4
      frequency     = "PT1H"
      window        = "PT1H"
      threshold     = 0
      operator      = "GreaterThan"
      periods       = 1
      evaluation    = 1
      metricmeasure = "Deadlocks"
    }
    ,
    {
      name          = "postgresql-cpu-and-query-pattern-alert"
      description   = "Alert triggered when high CPU usage is accompanied by unusual query patterns."
      display_name  = "PostgreSQL CPU and Query Pattern Anomalies"
      query         = <<-EOT
let HighCpuEvents = AzureMetrics
| where MetricName == 'cpu_percent'
| where Average > 90
| summarize by bin(TimeGenerated, 5m), _ResourceId;

let LongQueryEvents = AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" and Category == "QueryStoreRuntimeStatistics"
| where DurationMs > 10000
| summarize by bin(TimeGenerated, 5m), ResourceId;

HighCpuEvents
| join kind=inner LongQueryEvents on $left.TimeGenerated == $right.TimeGenerated and $left._ResourceId == $right.ResourceId
| summarize CombinedEventsCount = count() by bin(TimeGenerated, 5m), _ResourceId
| where CombinedEventsCount > 0
  EOT
      severity      = 3
      frequency     = "PT5M"
      window        = "PT15M"
      threshold     = 1
      operator      = "GreaterThan"
      periods       = 1
      evaluation    = 1
      metricmeasure = "CombinedEventsCount"
    }

    # Add more alert rules as needed
  ]
}