# Seed idempotente: cria um artigo demonstrativo somente se a tabela estiver vazia.
if Article.count.zero?
  Article.create!(
    title: "Por que comecei a escrever enquanto estudo",
    excerpt: "Um caderno público para organizar ideias, registrar descobertas e aprender construindo.",
    body: "# Aprender em público\n\nNem tudo precisa nascer como um tutorial perfeito. Às vezes, uma nota curta sobre algo que acabou de fazer sentido já vale o registro.\n\nEste espaço é para documentar o caminho: erros, perguntas, experimentos e pequenas vitórias.\n\n- Estudar com curiosidade\n- Registrar o que funcionou\n- Compartilhar sem fingir que sei tudo",
    status: "published",
    content_format: "markdown",
    published_at: Time.current
  )
end
