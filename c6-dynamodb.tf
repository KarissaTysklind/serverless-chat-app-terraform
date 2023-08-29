locals {
  dynamo_db_tables = {
    Chat_Conversation = {
      name      = var.dynamodb_conversation_table_name
      hash_key  = "ConversationId"
      range_key = "Username"
      attributes = [{
        name = "ConversationId"
        type = "S"
        },
        {
          name = "Username"
          type = "S"
        }
      ]
      global_secondary_indexes = [{
        name            = "Username-ConversationId-index"
        hash_key        = "Username"
        range_key       = "ConversationId"
        write_capacity  = 1
        read_capacity   = 1
        projection_type = "ALL"
        }
      ]
    }

    Chat_Messages = {
      name      = var.dynamodb_messages_table_name
      hash_key  = "ConversationId"
      range_key = "Timestamp"
      attributes = [{
        name = "ConversationId"
        type = "S"
        },
        {
          name = "Timestamp"
          type = "N"
        }
      ]
      global_secondary_indexes = []
    }
  }
}
module "dynamo_db_tables" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  for_each = local.dynamo_db_tables

  name                        = local.dynamo_db_tables[each.key].name
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  read_capacity               = 1
  write_capacity              = 1
  table_class                 = "STANDARD"

  hash_key                 = local.dynamo_db_tables[each.key].hash_key
  range_key                = local.dynamo_db_tables[each.key].range_key
  global_secondary_indexes = local.dynamo_db_tables[each.key].global_secondary_indexes

  attributes = local.dynamo_db_tables[each.key].attributes
  tags = {
    terraform = true
  }
}
