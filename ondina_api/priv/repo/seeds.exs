alias OndinaApi.Repo
alias OndinaApi.Catalog.Video

videos = [
  %{
    title: "Svelte 5 - O Futuro do Frontend",
    description: "Conheça o Svelte 5 com Runes, a atualização que vai mudar o jogo na reatividade granular.",
    thumbnail_url: "https://images.unsplash.com/photo-1627398240211-1a4a6cb9098d?q=80&w=2070&auto=format&fit=crop",
    video_url: "https://www.w3schools.com/html/mov_bbb.mp4",
    views: 12500
  },
  %{
    title: "Elixir & Phoenix para Alta Concorrência",
    description: "Por que a Erlang VM (BEAM) é a melhor escolha para sistemas que não podem falhar.",
    thumbnail_url: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=2070&auto=format&fit=crop",
    video_url: "https://www.w3schools.com/html/mov_bbb.mp4",
    views: 8900
  },
  %{
    title: "Design System Premium com Tailwind CSS",
    description: "Construindo interfaces incríveis em tempo recorde utilizando utilitários focados em UX.",
    thumbnail_url: "https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=2000&auto=format&fit=crop",
    video_url: "https://www.w3schools.com/html/mov_bbb.mp4",
    views: 42000
  },
  %{
    title: "Ondina - A Evolução do Streaming",
    description: "Conheça a plataforma de streaming definitiva desenhada do zero com performance máxima.",
    thumbnail_url: "https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=1974&auto=format&fit=crop",
    video_url: "https://www.w3schools.com/html/mov_bbb.mp4",
    views: 5500
  },
  %{
    title: "Glassmorphism & Micro-interações",
    description: "Como encantar seus usuários com feedbacks visuais dinâmicos e modernos na Web.",
    thumbnail_url: "https://images.unsplash.com/photo-1558655146-d09347e92766?q=80&w=1964&auto=format&fit=crop",
    video_url: "https://www.w3schools.com/html/mov_bbb.mp4",
    views: 31200
  },
  %{
    title: "Escalando Bancos PostgreSQL",
    description: "Aprenda arquiteturas de banco de dados modernas para suportar milhões de requests simultâneos.",
    thumbnail_url: "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?q=80&w=2036&auto=format&fit=crop",
    video_url: "https://www.w3schools.com/html/mov_bbb.mp4",
    views: 18450
  }
]

for video <- videos do
  Repo.insert!(Video.changeset(%Video{}, video))
end
