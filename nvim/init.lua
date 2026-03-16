-- ==========================================================================
-- Neovim 설정 진입점 (init.lua)
-- ==========================================================================
-- 이 파일은 Neovim 시작 시 가장 먼저 읽히는 파일입니다.
-- 각 설정을 별도의 모듈로 분리하여 관리합니다.
--
-- 파일 구조:
--   lua/options.lua  - 기본 에디터 옵션 (탭, 줄번호, 인코딩 등)
--   lua/keymaps.lua  - 키 매핑 (단축키 설정)
--   lua/plugins.lua  - 플러그인 목록 및 설정 (lazy.nvim)
--   lua/lsp.lua      - LSP(Language Server Protocol) 설정 (clangd 등)
-- ==========================================================================

-- 기본 에디터 옵션 로드
require("options")

-- 키 매핑 로드
require("keymaps")

-- 플러그인 매니저(lazy.nvim) 및 플러그인 로드
require("plugins")

-- LSP(Language Server Protocol) 설정 로드
require("lsp")
