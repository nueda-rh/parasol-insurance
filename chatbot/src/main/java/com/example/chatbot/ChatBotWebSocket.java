package com.example.chatbot;

import io.quarkus.websockets.next.OnOpen;
import io.quarkus.websockets.next.OnTextMessage;
import io.quarkus.websockets.next.WebSocket;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;

@WebSocket(path = "/chatbot")
public class ChatBotWebSocket {

    private final Bot bot;
    private ObjectMapper objectMapper = new ObjectMapper();

    public ChatBotWebSocket(Bot bot) {
        this.bot = bot;
    }

    @OnOpen
    public String onOpen() {
        return "{\"type\": \"token\", \"token\": \"\"}";
    }

    @OnTextMessage
    public String onMessage(String message) {
        String result = "{\"type\": \"token\", \"token\": \"エラーが発生しました。\"}";

        try {
            JsonNode jsonNode = objectMapper.readTree(message);
            String query = jsonNode.get("query").asText();
            String claim = jsonNode.get("claim").asText();
            String response = bot.chat(query, claim);

            response = response.replaceAll("\n", "\\\\n");
            result = "{\"type\": \"token\", \"token\": \"" + response + "\"}";
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return result;
    }

}
