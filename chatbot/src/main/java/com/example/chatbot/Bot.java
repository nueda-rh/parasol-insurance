package com.example.chatbot;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import io.quarkiverse.langchain4j.RegisterAiService;
import jakarta.enterprise.context.SessionScoped;

@RegisterAiService
@SessionScoped
public interface Bot {

    @SystemMessage("""
            あなたは『パラソルアシスタント』という名前の、助けになること、敬意を持つこと、正直であることを心がけるアシスタントです。
            常に安全であることを心がけてください。
            """)

    @UserMessage("""
            質問された内容について、請求の要約や参考情報に基づいて、可能な限り回答してください。

            ### 質問:
            {query}

            ### 請求の要約:
            {claim}
            """)
    String chat(String query, String claim);
}
