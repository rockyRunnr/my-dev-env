-- ==========================================================================
-- 플러그인 설정 (plugins.lua)
-- ==========================================================================
-- lazy.nvim 플러그인 매니저를 사용하여 플러그인을 관리합니다.
--
-- lazy.nvim이란?
--   - Neovim의 모던 플러그인 매니저
--   - 플러그인을 필요할 때만 로드(lazy-loading)하여 시작 속도를 빠르게 유지
--   - 처음 실행 시 자동으로 설치됨
--   - :Lazy 명령으로 플러그인 관리 UI를 열 수 있음
-- ==========================================================================

-- --------------------------------------------------------------------------
-- lazy.nvim 부트스트랩 (자동 설치)
-- --------------------------------------------------------------------------
-- 첫 실행 시 lazy.nvim이 없으면 GitHub에서 자동으로 클론합니다.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",                              -- 최소한의 데이터만 다운로드
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",                                  -- 안정 버전 사용
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)  -- lazy.nvim을 런타임 경로에 추가

-- --------------------------------------------------------------------------
-- 플러그인 목록 및 설정
-- --------------------------------------------------------------------------
require("lazy").setup({

  -- ========================================================================
  -- tokyonight.nvim - 모던 컬러스킴 (기존 jellybeans 대체)
  -- ========================================================================
  -- 눈이 편한 다크 테마입니다. 여러 변형(night, storm, day, moon)이 있습니다.
  {
    "folke/tokyonight.nvim",
    lazy = false,      -- 즉시 로드 (컬러스킴은 시작 시 필요)
    priority = 1000,   -- 다른 플러그인보다 먼저 로드
    config = function()
      require("tokyonight").setup({
        style = "night",  -- 스타일: "night"(어두움), "storm"(중간), "moon"(밝음)
        transparent = false,
        styles = {
          comments = { italic = true },   -- 주석을 이탤릭으로
          keywords = { italic = false },
        },
      })
      vim.cmd.colorscheme("tokyonight")  -- 컬러스킴 적용
    end,
  },

  -- ========================================================================
  -- telescope.nvim - 퍼지 검색 도구 (기존 fzf 대체)
  -- ========================================================================
  -- 파일 이름, 파일 내용(grep), 버퍼, 도움말 등을 빠르게 검색할 수 있습니다.
  -- <leader>ff로 파일 검색, <leader>fg로 텍스트 검색 등
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",                           -- 안정 버전 고정
    dependencies = { "nvim-lua/plenary.nvim" },  -- 필수 의존성 (유틸 라이브러리)
    config = function()
      require("telescope").setup({
        defaults = {
          -- 검색 결과 레이아웃
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.55,  -- 미리보기 창 너비 비율
            },
          },
          -- 검색에서 제외할 패턴 (빌드 산출물, .git 등)
          file_ignore_patterns = {
            "%.o$", "%.a$", "%.so$",    -- 컴파일된 오브젝트 파일
            "node_modules/",
            "%.git/",
            "build/",
          },
          mappings = {
            i = {  -- Insert 모드 (검색창에서 입력 중일 때)
              ["<C-j>"] = "move_selection_next",      -- 다음 항목으로 이동
              ["<C-k>"] = "move_selection_previous",  -- 이전 항목으로 이동
            },
          },
        },
      })
    end,
  },

  -- ========================================================================
  -- nvim-tree.lua - 파일 탐색기 (기존 NERDTree 대체)
  -- ========================================================================
  -- 화면 왼쪽에 디렉토리 트리를 표시합니다.
  -- <leader>e 로 열고 닫을 수 있습니다.
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },  -- 파일 아이콘 (선택사항)
    config = function()
      -- netrw(기본 파일 탐색기) 비활성화 (nvim-tree와 충돌 방지)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },  -- 파일명 정렬 시 대소문자 구분
        view = {
          width = 30,  -- 트리 창 너비 (글자 수)
        },
        renderer = {
          group_empty = true,  -- 빈 디렉토리는 한 줄로 합쳐서 표시
        },
        filters = {
          dotfiles = false,  -- 숨김 파일(.으로 시작하는 파일) 표시
        },
      })
    end,
  },

  -- ========================================================================
  -- lualine.nvim - 상태바 (기존 vim-airline 대체)
  -- ========================================================================
  -- 화면 하단에 현재 모드, 파일명, git 브랜치, 에러 수 등을 표시합니다.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",       -- 컬러스킴과 맞춤
          section_separators = "",    -- 구분자 비활성화 (깔끔한 모양)
          component_separators = "|", -- 컴포넌트 사이에 | 표시
        },
        sections = {
          -- 상태바 왼쪽: 모드 | 브랜치 | diff 정보
          lualine_a = { "mode" },              -- 현재 모드 (NORMAL, INSERT 등)
          lualine_b = { "branch", "diff" },    -- git 브랜치, 변경 통계(+/-/~)
          lualine_c = { "filename" },           -- 현재 파일 이름
          -- 상태바 오른쪽: 진단 | 인코딩 | 파일형식 | 위치
          lualine_x = { "diagnostics", "encoding", "filetype" },
          lualine_y = { "progress" },           -- 파일 내 위치 (%)
          lualine_z = { "location" },           -- 줄:열 번호
        },
        -- 상단에 버퍼(탭) 목록 표시 (기존 airline tabline과 동일한 역할)
        tabline = {
          lualine_a = { "buffers" },  -- 열린 버퍼 목록을 탭처럼 표시
          lualine_z = { "tabs" },     -- 실제 탭 목록
        },
      })
    end,
  },

  -- ========================================================================
  -- nvim-lspconfig - LSP(Language Server Protocol) 설정
  -- ========================================================================
  -- 에디터에서 IDE 수준의 기능을 사용할 수 있게 해주는 핵심 플러그인입니다.
  -- clangd(C/C++), pyright(Python) 등 언어 서버와 연동합니다.
  -- 실제 LSP 설정은 lsp.lua에서 합니다.
  -- nvim-lspconfig v1.x 사용 (Neovim 0.10 호환)
  { "neovim/nvim-lspconfig", tag = "v1.8.0" },

  -- ========================================================================
  -- nvim-cmp - 자동완성 엔진
  -- ========================================================================
  -- 코드 작성 중 자동완성 팝업을 표시합니다.
  -- LSP, 스니펫, 버퍼 내 단어 등 여러 소스에서 완성 후보를 가져옵니다.
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP 자동완성 소스 (함수, 변수, 타입 등)
      "hrsh7th/cmp-buffer",     -- 현재 버퍼의 단어로 자동완성
      "hrsh7th/cmp-path",       -- 파일 경로 자동완성
      "hrsh7th/cmp-cmdline",    -- 명령줄(:) 자동완성
      "L3MON4D3/LuaSnip",      -- 스니펫 엔진 (코드 조각 템플릿)
      "saadparwaiz1/cmp_luasnip", -- LuaSnip과 nvim-cmp 연동
    },
    -- 자동완성 설정은 lsp.lua에서 함께 진행합니다.
  },

  -- ========================================================================
  -- nvim-treesitter - 향상된 구문 강조
  -- ========================================================================
  -- 코드의 구문 트리(AST)를 분석하여 정확한 구문 강조를 제공합니다.
  -- 기존의 정규식 기반 하이라이팅보다 훨씬 정확합니다.
  -- 자동으로 동작하므로 별도 조작이 필요 없습니다.
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.3",    -- Neovim 0.10 호환 버전 (v0.10.0은 API 변경됨)
    build = ":TSUpdate",  -- 설치/업데이트 시 파서도 업데이트
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 자동 설치할 언어 파서 목록
        ensure_installed = {
          "c", "cpp",          -- C/C++ (HANA 개발)
          "python",            -- Python 스크립트
          "lua",               -- Neovim 설정 파일
          "cmake",             -- CMakeLists.txt
          "bash",              -- 셸 스크립트
          "json", "yaml",     -- 설정 파일
          "markdown",          -- 문서
          "vim", "vimdoc",     -- Vim 도움말
        },
        highlight = {
          enable = true,  -- treesitter 구문 강조 활성화
        },
        indent = {
          enable = true,  -- treesitter 기반 자동 들여쓰기
        },
      })
    end,
  },

  -- ========================================================================
  -- gitsigns.nvim - git 변경 표시 (기존 vim-gitgutter 대체)
  -- ========================================================================
  -- 편집기 왼쪽에 git 변경 상태를 표시합니다:
  --   │ (초록) = 추가된 줄, │ (파랑) = 수정된 줄, _ (빨강) = 삭제된 줄
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },   -- 새로 추가된 줄
          change       = { text = "│" },   -- 수정된 줄
          delete       = { text = "_" },   -- 삭제된 줄
          topdelete    = { text = "‾" },   -- 위쪽이 삭제된 줄
          changedelete = { text = "~" },   -- 수정 후 삭제
        },
        -- 키 매핑: hunk(변경 단위) 탐색 및 조작
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function bmap(mode, l, r, o)
            o = o or {}
            o.buffer = bufnr
            vim.keymap.set(mode, l, r, o)
          end

          -- hunk 간 이동
          bmap("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "다음 변경(hunk)으로 이동" })

          bmap("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "이전 변경(hunk)으로 이동" })

          -- hunk 조작
          bmap("n", "<leader>hs", gs.stage_hunk, { desc = "변경(hunk) 스테이지" })
          bmap("n", "<leader>hr", gs.reset_hunk, { desc = "변경(hunk) 리셋" })
          bmap("n", "<leader>hp", gs.preview_hunk, { desc = "변경(hunk) 미리보기" })
          bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end,
            { desc = "현재 줄 blame 보기" })
        end,
      })
    end,
  },

  -- ========================================================================
  -- vim-fugitive - git 명령어 통합
  -- ========================================================================
  -- Vim 안에서 git 명령어를 실행할 수 있습니다.
  -- :Git status, :Git diff, :Git blame, :Git log 등
  -- Vim 플러그인 생태계에서 가장 성숙한 git 도구입니다.
  { "tpope/vim-fugitive" },

  -- ========================================================================
  -- indent-blankline.nvim - 들여쓰기 가이드라인
  -- ========================================================================
  -- 들여쓰기 레벨마다 세로 줄을 표시하여 코드 구조를 시각적으로 보여줍니다.
  -- 깊은 중첩에서 어떤 블록에 속하는지 쉽게 파악할 수 있습니다.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },  -- 들여쓰기 가이드라인 문자
        scope = { enabled = true },  -- 현재 스코프(블록) 강조
      })
    end,
  },

  -- ========================================================================
  -- Comment.nvim - 주석 토글
  -- ========================================================================
  -- 간단하게 코드 주석을 켜고 끌 수 있습니다.
  --   gcc = 현재 줄 주석 토글
  --   gc  = Visual 모드에서 선택 영역 주석 토글
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()  -- 기본 설정 사용
    end,
  },

}, {
  -- lazy.nvim 자체 옵션
  checker = {
    enabled = false,  -- 자동 플러그인 업데이트 체크 비활성화
  },
  performance = {
    rtp = {
      -- 사용하지 않는 기본 플러그인 비활성화 (시작 속도 향상)
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
