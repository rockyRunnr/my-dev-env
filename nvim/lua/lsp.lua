-- ==========================================================================
-- LSP(Language Server Protocol) 설정 (lsp.lua)
-- ==========================================================================
-- LSP란?
--   에디터와 언어 서버(예: clangd) 사이의 통신 프로토콜입니다.
--   이를 통해 에디터에서 IDE 수준의 기능을 사용할 수 있습니다:
--   - 코드 자동완성
--   - 정의로 이동 (Go to Definition)
--   - 참조 찾기 (Find References)
--   - 에러/경고 실시간 표시
--   - 호버 정보 (함수 시그니처, 문서)
--   - 이름 변경 (Rename)
--
-- clangd란?
--   LLVM/Clang 프로젝트의 C/C++ 언어 서버입니다.
--   HANA 코드베이스의 C++ 파일에서 자동완성, 정의 이동 등을 제공합니다.
-- ==========================================================================

-- --------------------------------------------------------------------------
-- nvim-cmp (자동완성) 설정
-- --------------------------------------------------------------------------
local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
  vim.notify("nvim-cmp을 로드할 수 없습니다. 자동완성이 비활성화됩니다.", vim.log.levels.WARN)
  return
end

local luasnip_ok, luasnip = pcall(require, "luasnip")

cmp.setup({
  -- 스니펫 엔진 설정
  snippet = {
    expand = function(args)
      if luasnip_ok then
        luasnip.lsp_expand(args.body)  -- 스니펫 확장
      end
    end,
  },

  -- 자동완성 팝업에서의 키 매핑
  mapping = cmp.mapping.preset.insert({
    -- 자동완성 후보 탐색
    ["<C-k>"] = cmp.mapping.select_prev_item(),  -- 이전 항목 (위로)
    ["<C-j>"] = cmp.mapping.select_next_item(),  -- 다음 항목 (아래로)

    -- 문서 스크롤 (자동완성 항목의 상세 설명)
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),  -- 문서 위로 스크롤
    ["<C-f>"] = cmp.mapping.scroll_docs(4),   -- 문서 아래로 스크롤

    -- 자동완성 트리거/닫기
    ["<C-Space>"] = cmp.mapping.complete(),   -- 수동으로 자동완성 팝업 열기
    ["<C-e>"] = cmp.mapping.abort(),          -- 자동완성 팝업 닫기

    -- 선택 확정
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,  -- false = 명시적으로 선택한 항목만 확정
                       -- true로 하면 첫 번째 항목이 자동 선택됨
    }),

    -- Tab으로 자동완성 / 스니펫 이동
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()            -- 자동완성 팝업이 열려있으면 다음 항목
      elseif luasnip_ok and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()          -- 스니펫 내에서 다음 위치로 점프
      else
        fallback()                        -- 그 외에는 일반 탭
      end
    end, { "i", "s" }),

    -- Shift+Tab으로 이전 항목 / 스니펫 역방향 이동
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip_ok and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  -- 자동완성 소스 (우선순위 순서)
  sources = cmp.config.sources({
    { name = "nvim_lsp" },   -- LSP (clangd 등)에서 제공하는 완성 후보 (최우선)
    { name = "luasnip" },    -- 스니펫
  }, {
    { name = "buffer" },     -- 현재 버퍼의 단어 (LSP가 없을 때 폴백)
    { name = "path" },       -- 파일 경로
  }),

  -- 자동완성 팝업 모양
  window = {
    completion = cmp.config.window.bordered(),     -- 테두리 있는 팝업
    documentation = cmp.config.window.bordered(),  -- 문서 팝업에도 테두리
  },
})

-- 명령줄(:)에서도 자동완성 활성화
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

-- --------------------------------------------------------------------------
-- LSP 서버 설정
-- --------------------------------------------------------------------------
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  vim.notify("nvim-lspconfig을 로드할 수 없습니다. LSP가 비활성화됩니다.", vim.log.levels.WARN)
  return
end

-- nvim-cmp의 LSP 능력(capabilities)을 LSP 서버에 전달
-- 이것을 해야 자동완성이 LSP와 연동됩니다.
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- --------------------------------------------------------------------------
-- LSP 버퍼 연결 시 키맵 설정 (on_attach)
-- --------------------------------------------------------------------------
-- LSP 서버가 버퍼에 연결되었을 때 실행되는 함수입니다.
-- 여기서 LSP 관련 키맵을 버퍼 로컬로 설정합니다.
local on_attach = function(client, bufnr)
  local bmap = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
  end

  -- 코드 탐색 (g 접두사 키맵)
  bmap("n", "gd", vim.lsp.buf.definition, "정의로 이동 (Go to Definition)")
  bmap("n", "gD", vim.lsp.buf.declaration, "선언으로 이동 (Go to Declaration)")
  bmap("n", "gr", vim.lsp.buf.references, "참조 찾기 (Find References)")
  bmap("n", "gi", vim.lsp.buf.implementation, "구현으로 이동 (Go to Implementation)")
  bmap("n", "gt", vim.lsp.buf.type_definition, "타입 정의로 이동")

  -- 코드 탐색 (Leader 키맵 - 기존 .vimrc 습관 유지)
  bmap("n", "<leader>d", vim.lsp.buf.definition, "정의로 이동 (,d)")
  bmap("n", "<leader>r", vim.lsp.buf.references, "참조 찾기 (,r)")
  bmap("n", "<leader>i", vim.lsp.buf.implementation, "구현으로 이동 (,i)")

  -- 정보 표시
  bmap("n", "K", vim.lsp.buf.hover, "호버 정보 (타입, 문서)")
  bmap("n", "<C-k>", vim.lsp.buf.signature_help, "함수 시그니처 도움말")

  -- 코드 수정
  bmap("n", "<leader>rn", vim.lsp.buf.rename, "이름 변경 (Rename)")
  bmap("n", "<leader>ca", vim.lsp.buf.code_action, "코드 액션 (Code Action)")
  bmap("n", "<F12>", vim.lsp.buf.definition, "정의로 이동 (F12)")

  -- 진단(에러/경고) 탐색
  bmap("n", "[d", vim.diagnostic.goto_prev, "이전 진단(에러/경고)으로 이동")
  bmap("n", "]d", vim.diagnostic.goto_next, "다음 진단(에러/경고)으로 이동")
  bmap("n", "<leader>dl", vim.diagnostic.setloclist, "진단 목록 열기")
  bmap("n", "<leader>dd", vim.diagnostic.open_float, "현재 줄 진단 팝업으로 보기")
end

-- --------------------------------------------------------------------------
-- 진단(Diagnostics) 표시 설정
-- --------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",      -- 에러/경고 아이콘
    spacing = 4,       -- 코드와 진단 메시지 사이 간격
  },
  signs = true,         -- 왼쪽 기호 열에 아이콘 표시
  underline = true,     -- 에러가 있는 코드에 밑줄
  update_in_insert = false,  -- Insert 모드에서는 업데이트 안 함 (타이핑 방해 방지)
  severity_sort = true, -- 심각도 순으로 정렬 (에러 > 경고 > 정보 > 힌트)
})

-- 진단 아이콘 설정
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- --------------------------------------------------------------------------
-- clangd 설정 (C/C++ 언어 서버)
-- --------------------------------------------------------------------------
-- HANA C++ 개발의 핵심 도구입니다.
-- compile_commands.json이 빌드 디렉토리에 있어야 clangd가 정상 동작합니다.
-- (hm init -b <profile> 실행 시 자동 생성됨)
lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",                        -- clangd 실행 파일 (PATH에서 자동 찾음)
    "--background-index",            -- 백그라운드에서 인덱싱 (대규모 프로젝트에 유용)
    "--clang-tidy",                  -- clang-tidy 경고도 표시
    "--header-insertion=iwyu",       -- include 자동 추가
    "--completion-style=detailed",   -- 자동완성 시 상세 정보 표시
    "--fallback-style=llvm",         -- 포맷 스타일 폴백
    "-j=4",                          -- 인덱싱 스레드 수
  },
  -- C/C++ 파일에서만 활성화
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
})

-- --------------------------------------------------------------------------
-- 추가 LSP 서버 (필요 시 활성화)
-- --------------------------------------------------------------------------
-- Python (pyright) - pip install pyright 후 주석 해제
-- lspconfig.pyright.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
-- })

-- Lua (lua_ls) - Neovim 설정 파일 편집 시 유용
-- lspconfig.lua_ls.setup({
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = {
--     Lua = {
--       runtime = { version = "LuaJIT" },
--       diagnostics = { globals = { "vim" } },
--     },
--   },
-- })
