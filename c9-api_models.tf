locals {
  api_models = {
    conversation_list = {
        name = "ConversationList"
        file_name = "ConversationList.json"
    }

    conversation = {
        name = "Conversation"
        file_name = "Conversation.json"
    }

    conversation_id = {
        name = "ConversationId"
        file_name = "ConversationId.json"
    }

    new_conversation = {
        name = "NewConversation"
        file_name = "NewConversation.json"
    }

    new_message = {
        name = "NewMessage"
        file_name = "NewMessage.json"
    }

    user_list = {
        name = "UserList"
        file_name = "UserList.json"
    }
  }
}

resource "aws_api_gateway_model" "chat_models" {
    for_each = local.api_models
    rest_api_id = aws_api_gateway_rest_api.chat.id
    name = local.api_models[each.key].name
    content_type = "application/json"
    schema = file("${path.module}/models/${local.api_models[each.key].file_name}")
}