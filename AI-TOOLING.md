# AI tooling – közös Claude Code és Codex munkafolyamat

A hordozható beállításokat a chezmoi kezeli. A telepített verziók forrása a
`dot_config/mise/config.toml.tmpl`; a modelleké a `dot_claude/MODEL-MATRIX.md`.
Az adott gép bejelentkezése és a futó kliensek állapota nem következik a konfigurációból.

## Közös szabályok és routing

- Codex és Claude egyenrangú elsődleges agent. Az aktuális session implementál,
  ellenőriz és befejezi a feladatot; a másik agent kérhető független tanácsra.
- A `.chezmoitemplates/global-agent-policy.md` mindkét globális utasítás forrása:
  `~/.codex/AGENTS.md` és `~/.claude/CLAUDE.md`.
- Széles vagy drága delegálás előtt `agent-quota`, majd `agent-route <class>`.
  Ismeretlen kvóta nem jelent szabad kapacitást. Önmagának nem delegál az agent.
- Explicit kliensválasztás: `agent-route review --agent claude` vagy `--agent codex`.
  A script sessionkörnyezetből is detektál, illetve az `AGENT_ROUTING_AGENT` változóval
  állítható. Kvóta- és költségszűrés után az aktuális agent élvez elsőbbséget.

| Kategória | Feladat | Codex modell |
|---|---|---|
| `cheap` | Apró mechanikus munka, formázás, logtriage | Sol mint fallback; Haiku/Flash is választható |
| `code` | Feature, bugfix, refaktor | GPT-6.1 Sol |
| `review` | Kód-/PR-review, végső ellenőrzés | GPT-6.1 Sol, read-only; Astra eszkaláció |
| `hard` | Architektúra, összetett security/debug | GPT-6 Astra |
| `long` | Hosszú implementáció és nagy kontextus | GPT-6.1 Sol |
| `orchestrate` | Agentkoordináció, implementáció/review ciklusok | GPT-6 Astra |

Claude megtartja a sessionben kiválasztott modelljét. GPT-6.1 Terra csak értékelendő
jelölt, nem automatikus route. Az Ollama kikerült a routingból. A pontos fallback
láncokat és korlátokat a modellmátrix írja le.

## Segédparancsok és telepítés

| Parancs | Feladat |
|---|---|
| `bootstrap-ai-toolstack` | Mise-csomagok telepítése, MCP-regisztráció, pluginek, Codex-defaultok és hookok összeolvasztása |
| `update-ai-toolstack` | Codex marketplace-frissítés, minden user-szintű Claude plugin frissítése, deklarált mise-verziók telepítése, bootstrap |
| `check-ai-toolstack` | Parancsok, configok, hookok és MCP-k ellenőrzése; figyelmeztetés PATH-verzióeltérésre |
| `agent-health` | Élő smoke test; modellhívást is végezhet |
| `agent-quota` | Lokális kvóta- és használati bizonyítékok |
| `agent-route` | Feladatosztály szerinti ajánlás; kvótakimerülésnél modellprobe is történhet |
| `agent-ask-codex` | Claude-ból Codex tanács; alapból read-only, Sol modellel |
| `agent-ask-claude` | Codexből Claude tanács, plan módban; költségplafon csak explicit `CLAUDE_MAX_BUDGET_USD` esetén |
| `agent-ask-gemini` | Opcionális Gemini Flash tanács meglévő API-kulccsal |
| `matrix-evidence` | Offline modellmátrix-frissességi ellenőrzés |
| `configure-agent-defaults`, `configure-agent-hooks` | Codex-beállítások merge-je idegen bejegyzések megtartásával |

A `chezmoi apply` fájlokat telepít, önmagában nem futtatja a bootstrapet.
A `TOOLSTACK_SKIP_MISE=1` kihagyja a csomagtelepítést. A rögzített verziók
emelése a mise-manifest módosításával történik; a `mise install` nem írja át őket
önkényesen a legújabbra. A frissítő hibás részlépés esetén hibakóddal tér vissza;
a kikapcsolt Claude plugineket frissíti, de nem kapcsolja be.

## Kódfelderítés és indexek

| Eszköz | Elsődleges szerep |
|---|---|
| codebase-memory | Szimbólumok, hívási láncok, kódgráf és pontos kódrészletek |
| Repowise | Architektúra, függőségek, hatáselemzés és kód-health; opcionális wiki |
| CodeGraph | Opcionális strukturális kódgráf; meglévő `.codegraph/codegraph.db` kell |
| `rg`, ast-grep, FFF | Literális, szintaxisalapú és fájlkeresés |
| Context7 | Aktuális library/framework/API-dokumentáció |

Minden Claude Code- és Codex-projektfeladat elején létre kell hozni a hiányzó
codebase-memory és Repowise indexet. Pull, branch/worktree-váltás, külső módosítás
és minden összefüggő saját forrásmódosítás után frissíteni kell őket, a nem commitolt
és új fájlokat is beleértve. Frissítés után ellenőrizni kell a befejezést.
Csak az érintett repók indexelhetők, umbrella mappa és idegen repók nem.
A pontos, ellenőrzött parancsokat a közös globális policy tartalmazza.

Az automatikus Repowise-futtatás gyors indexet készít modellhívás nélkül; nem írja
felül az AGENTS.md/CLAUDE.md fájlokat, az editorconfigot vagy a git hookokat.
A codebase-memory alapból a saját cache-ét használja, `persistence=false` mellett.
Az indexek hibája nem akadályozza a hasznos munkát, de a hibát jelezni kell.

A `dot_config/git/ignore` globálisan kizárja a `.repowise/`, `.codebase-memory/`
és `.codegraph/` könyvtárakat. Nem szükséges ezek miatt megváltoztatni a projektek
közös `.gitignore` fájlját. A már követett fájlokat az ignore nem távolítja el Gitből.

## MCP-k és kliensenkénti különbségek

A bootstrap mindkét agenthez regisztrálja a rendelkezésre álló Context7,
codebase-memory, CodeGraph, Repowise, Playwright, Nx, DDGS és Homebrew MCP-ket.
FFF opcionálisan telepíthető; Clockifyhoz `CLOCKIFY_API_KEY` kell.
A regisztráció, a működő kapcsolat és a sikeres hitelesítés külön ellenőrzés.

Claude Desktop nem rendelkezik projekt-cwd-vel, ezért oda nem kerül CodeGraph,
FFF, Nx vagy Repowise. Ha Desktop fut a bootstrap alatt, a memóriából visszaírhatja
régi konfigurációját: be kell zárni, majd újrafuttatni a bootstrapet.
A projekt-MCP-k Claude Code-ban és Codexben használhatók.

## Pluginek, skillek és hookok

- Superpowers: közös folyamat-skillek; bootstrap mindkét klienshez telepíti.
- Ponytail: egyszerű implementáció és kis diff; Claude-hoz a bootstrap telepíti,
  Codexhez az update-script biztosítja a konfigurált marketplace-ről.
- Hivatalos `codex@openai-codex`: Claude-ból Codex app-server integráció;
  a CLI fallback az `agent-ask-codex`. A régi `codex mcp-server` nem használható.
- Caveman: tömör kommunikáció; a meglévő Claude plugint a frissítő kezeli.
- CodeRabbit CLI: külső AI-review, külön telepítéssel/hitelesítéssel.
  Kézi review nem nevezhető CodeRabbit-eredménynek.
- `gpt-toolset`, `find-skills`, Playwright- és Rust-skillek: megosztott szakmai útmutatók.
- Dokumentum-, böngésző- és szolgáltatáspluginek kliensfüggők; a listájuk nem
  jelent automatikus telepítést vagy azonos jogosultságokat mindkét kliensben.

A route-gate és route-enforce mindkét agentben működik:
`route: <solo|codex|claude|gemini> reason=<indok>`. A közös session-emlékeztető
az indexelési policyra is felhívja a figyelmet. Claude-ban a codebase-memory
PreToolUse hook a keresést egészíti ki; Codex hookjait a configure-script merge-eli.
RTK szűri a shellkimenetet, Codeburn mér, Headroom kontextust kezel.
A Claude attribúciós beállítás nem ad automatikus commit-/PR-aláírást vagy sessionlinket.

## Másik gépen és karbantartáskor

```bash
chezmoi apply
bootstrap-ai-toolstack
check-ai-toolstack
python3 ~/.local/share/chezmoi/tests/check_agent_setup.py
python3 ~/.local/share/chezmoi/tests/check_toolstack_update.py
```

Csak konfigurációfrissítéshez: `TOOLSTACK_SKIP_MISE=1 bootstrap-ai-toolstack`.
Pluginek és csomagok karbantartásához: `update-ai-toolstack`.
Frissítés után a futó klienseket újra kell tölteni vagy indítani.
A Postman és más OAuth-szolgáltatások hitelesítését az új gépen külön kell elvégezni.

Nem kerül a repóba: API-kulcs, `.env`, authadat, session-/route-log, cache és
indexadatbázis. Az opcionális eszközök, accountállapotok és futó szolgáltatások
gépenként eltérhetnek.
