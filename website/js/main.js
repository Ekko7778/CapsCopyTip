// ===== i18n =====
const i18n = {
    zh: {
        'nav.features': '功能',
        'nav.preview': '预览',
        'nav.download': '下载',
        'nav.changelog': '更新日志',
        'hero.eyebrow': 'v2.0.10 · 已发布',
        'hero.subtitle': '轻量 Windows 桌面状态提示工具',
        'hero.desc': '在屏幕上实时显示键盘状态和剪贴板操作反馈，帮助你准确感知输入环境。',
        'hero.download': '下载最新版',
        'features.eyebrow': '功能特性',
        'features.title': '核心功能',
        'features.titleAccent': '· 一目了然',
        'features.subtitle': '简洁、轻量、不打断你的工作流',
        'features.caps.title': '大小写状态检测',
        'features.caps.desc': '切换 CapsLock 或按下 Shift 时，在光标旁即时显示当前大小写状态。配合输入法中英文检测，输入环境一目了然。',
        'features.ime.title': '输入法中/英提示',
        'features.ime.desc': '自动检测当前输入法状态，与大小写提示一同显示。',
        'features.copy.title': '复制操作反馈',
        'features.copy.desc': '复制文本、截图或文件时，显示复制的字符数或文件数量。',
        'features.copy.demo1': '已复制：42 字符',
        'features.copy.demo2': '已复制：图片',
        'preview.eyebrow': '效果预览',
        'preview.title': '效果预览',
        'preview.subtitle': '深色 / 浅色主题，跟随你的系统偏好',
        'preview.caps': '大小写 + 输入法提示',
        'preview.copy': '复制提示',
        'demo.hint.caps': '按下 Caps Lock',
        'demo.hint.copy': '按下 Ctrl + C',
        'demo.caps.text': '小写｜中',
        'demo.copy.text': '已复制：11 字符',
        'demo.caps.capsEn': '大写｜英',
        'demo.caps.capsCn': '大写｜中',
        'demo.caps.lowerEn': '小写｜英',
        'demo.caps.lowerCn': '小写｜中',
        'download.eyebrow': '开始使用',
        'download.title': '获取',
        'download.subtitle': '无需安装，下载即用',
        'download.step1.title': '下载',
        'download.step1.desc': '从 GitHub Releases 下载最新版 ZIP 包',
        'download.step2.title': '解压',
        'download.step2.desc': '解压到任意目录',
        'download.step3.title': '运行',
        'download.step3.desc': '双击 CursorTip.exe，无需安装 AutoHotkey',
        'download.btn': '下载最新版',
        'download.noInstall': '无需安装 AutoHotkey',
        'changelog.eyebrow': '更新日志',
        'changelog.title': '更新日志',
        'changelog.subtitle': '持续迭代，越来越好',
        'changelog.v2.0.10': '优化剪贴板读取逻辑，增加等待与异常处理',
        'changelog.v2.0.1': '移除 Ctrl+Space 输入法追踪，仅保留 Shift 翻转',
        'changelog.v2.0.0': '项目重命名为 CursorTip，优化剪贴板去重逻辑',
        'changelog.v1.0.10': '升级为二十进制版本规范',
        'changelog.v1.0.8': '引入 DefaultConfig，设置窗口 UI 重构，内存泄漏修复',
        'changelog.viewAll': '查看全部版本',
        'footer.releases': 'Releases',
        'footer.copy': '© 2026 CursorTip. 使用 AutoHotkey v2 构建',
        'footer.cta': '❤️ 觉得不错？点个 Star'
    },
    en: {
        'nav.features': 'Features',
        'nav.preview': 'Preview',
        'nav.download': 'Download',
        'nav.changelog': 'Changelog',
        'hero.eyebrow': 'v2.0.10 · released',
        'hero.subtitle': 'Lightweight Windows Desktop Status Indicator',
        'hero.desc': 'Real-time keyboard status and clipboard feedback on screen, helping you stay aware of your input environment.',
        'hero.download': 'Download Latest',
        'features.eyebrow': 'FEATURES',
        'features.title': 'Core Features',
        'features.titleAccent': '· at a glance',
        'features.subtitle': 'Simple, lightweight, never interrupts your workflow',
        'features.caps.title': 'CapsLock Detection',
        'features.caps.desc': 'Instantly shows current CapsLock state near your cursor when toggling or pressing Shift — combined with IME language detection for full input awareness.',
        'features.ime.title': 'IME Language Hint',
        'features.ime.desc': 'Automatically detects input method state, shown alongside the CapsLock indicator.',
        'features.copy.title': 'Copy Feedback',
        'features.copy.desc': 'Shows character count or file count when you copy text, screenshots, or files.',
        'features.copy.demo1': 'Copied: 42 chars',
        'features.copy.demo2': 'Copied: Image',
        'preview.eyebrow': 'PREVIEW',
        'preview.title': 'See it in action',
        'preview.subtitle': 'Dark / Light themes, follows your system preference',
        'preview.caps': 'CapsLock + IME Indicator',
        'preview.copy': 'Copy Feedback',
        'demo.hint.caps': 'Press Caps Lock',
        'demo.hint.copy': 'Press Ctrl + C',
        'demo.caps.text': 'lowercase | CN',
        'demo.copy.text': 'Copied: 11 char(s)',
        'demo.caps.capsEn': 'CAPS | EN',
        'demo.caps.capsCn': 'CAPS | ZH',
        'demo.caps.lowerEn': 'caps | EN',
        'demo.caps.lowerCn': 'caps | ZH',
        'download.eyebrow': 'GET STARTED',
        'download.title': 'Get',
        'download.subtitle': 'No installation needed, just download and run',
        'download.step1.title': 'Download',
        'download.step1.desc': 'Get the latest ZIP from GitHub Releases',
        'download.step2.title': 'Extract',
        'download.step2.desc': 'Unzip to any folder',
        'download.step3.title': 'Run',
        'download.step3.desc': 'Double-click CursorTip.exe, no AutoHotkey required',
        'download.btn': 'Download Latest',
        'download.noInstall': 'No AutoHotkey Required',
        'changelog.eyebrow': 'CHANGELOG',
        'changelog.title': 'Changelog',
        'changelog.subtitle': 'Continuously improving',
        'changelog.v2.0.10': 'Improved clipboard reading with wait and error handling',
        'changelog.v2.0.1': 'Removed Ctrl+Space IME tracking, keeping only Shift toggle',
        'changelog.v2.0.0': 'Renamed to CursorTip, optimized clipboard dedup logic',
        'changelog.v1.0.10': 'Upgraded to vigesimal versioning scheme',
        'changelog.v1.0.8': 'DefaultConfig, settings UI overhaul, memory leak fixes',
        'changelog.viewAll': 'View All Releases',
        'footer.releases': 'Releases',
        'footer.copy': '© 2026 CursorTip. Built with AutoHotkey v2',
        'footer.cta': '❤️ Like it? Give a Star'
    }
};

// 检测系统语言，如果没有缓存则自动选择
const getSystemLang = () => {
    const lang = navigator.language || navigator.userLanguage || 'zh';
    return lang.startsWith('zh') ? 'zh' : 'en';
};
let currentLang = localStorage.getItem('cursortip-lang') || getSystemLang();

function applyLang(lang) {
    currentLang = lang;
    localStorage.setItem('cursortip-lang', lang);
    document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';

    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (i18n[lang][key]) {
            el.textContent = i18n[lang][key];
        }
    });

    document.querySelector('.lang-label').textContent = lang === 'zh' ? 'EN' : '中';

    // Refresh hero version badge with current language (uses cached releases)
    updateHeroVersion();
}

function toggleLang() {
    applyLang(currentLang === 'zh' ? 'en' : 'zh');
}

// Download latest release
let cachedDownloadUrl = null;

async function downloadLatest(e) {
    e.preventDefault();

    if (cachedDownloadUrl) {
        window.location.href = cachedDownloadUrl;
        return;
    }

    try {
        const res = await fetch('https://api.github.com/repos/zeno528/CursorTip/releases/latest');
        const data = await res.json();
        const asset = data.assets?.find(a => a.name.endsWith('.zip'));
        if (asset?.browser_download_url) {
            cachedDownloadUrl = asset.browser_download_url;
            window.location.href = cachedDownloadUrl;
        } else {
            window.open('https://github.com/zeno528/CursorTip/releases/latest', '_blank');
        }
    } catch {
        window.open('https://github.com/zeno528/CursorTip/releases/latest', '_blank');
    }
}

// ===== Dynamic Releases (from GitHub Releases API) =====
// Single source of truth: GitHub Releases → website auto-syncs.
// Each GitHub Release's body becomes the changelog description.
const RELEASES_API = 'https://api.github.com/repos/zeno528/CursorTip/releases?per_page=10';
const RELEASES_CACHE_KEY = 'cursortip-releases-v1';
const RELEASES_CACHE_TTL = 15 * 60 * 1000; // 15 min

let releasesCache = null;

async function fetchReleases() {
    // 1. In-memory cache (survives within page lifetime; refresh clears it)
    if (releasesCache) return releasesCache;

    // 2. localStorage cache
    try {
        const stored = localStorage.getItem(RELEASES_CACHE_KEY);
        if (stored) {
            const { data, time } = JSON.parse(stored);
            if (Date.now() - time < RELEASES_CACHE_TTL && Array.isArray(data)) {
                releasesCache = data;
                return data;
            }
        }
    } catch { /* localStorage unavailable */ }

    // 3. Fetch from GitHub API
    try {
        const res = await fetch(RELEASES_API, {
            headers: { 'Accept': 'application/vnd.github+json' }
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        // Only stable releases
        const stable = Array.isArray(data)
            ? data.filter(r => r && !r.draft && !r.prerelease)
            : [];
        releasesCache = stable;
        try {
            localStorage.setItem(RELEASES_CACHE_KEY, JSON.stringify({
                data: stable,
                time: Date.now()
            }));
        } catch { /* quota exceeded — ignore */ }
        return stable;
    } catch (e) {
        console.warn('[CursorTip] Failed to fetch releases:', e.message);
        return releasesCache || []; // Return stale cache or empty
    }
}

// Extract first meaningful line from a release body (markdown)
// Strategy:
//   1. Find all bullet points, skip very short ones (< 8 chars — usually emoji section labels like "🐞 修复问题")
//   2. Return the first meaningful bullet
//   3. If no bullets, fall back to the first non-heading/callout line
function parseReleaseBody(body) {
    if (!body) return '';
    const lines = body.split('\n').map(l => l.trim()).filter(Boolean);

    // Strip inline markdown formatting from a text snippet
    const clean = (text) => text
        .replace(/\*\*([^*]+)\*\*/g, '$1')   // **bold**
        .replace(/\*([^*]+)\*/g, '$1')        // *italic*
        .replace(/`([^`]+)`/g, '$1')          // `code`
        .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1') // [text](url) → text
        .trim();

    const truncate = (s) => s.length > 100 ? s.substring(0, 100) + '…' : s;

    // Pass 1: collect all bullets, then pick the first "meaningful" one
    const bullets = [];
    for (const line of lines) {
        const m = line.match(/^[-*+]\s+(.+)$/) || line.match(/^\d+\.\s+(.+)$/);
        if (m) bullets.push(clean(m[1]));
    }
    // Prefer bullets with >= 8 visible chars (skip emoji section labels)
    const meaningful = bullets.find(b => b.length >= 8);
    if (meaningful) return truncate(meaningful);
    // Fall back to the first bullet if all are short
    if (bullets.length > 0) return truncate(bullets[0]);

    // Pass 2: no bullets — use first non-heading/callout line
    for (const line of lines) {
        if (line.startsWith('#')) continue;
        if (line.startsWith('>')) continue;
        if (/^https?:\/\//i.test(line)) continue;
        if (/^!\[/.test(line)) continue;
        if (/^\*\*[^*]*\*\*:?\s*$/.test(line)) continue;
        const c = clean(line.replace(/^[-*+]\s+/, '').replace(/^\d+\.\s+/, ''));
        if (c.length >= 6) return truncate(c);
    }
    return ''; // Caller will use fallback
}

function formatReleaseDate(isoDate) {
    if (!isoDate) return '';
    try {
        const d = new Date(isoDate);
        return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    } catch {
        return '';
    }
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

// Render the changelog timeline from releases
async function renderChangelog() {
    const releases = await fetchReleases();
    const timeline = document.querySelector('.timeline');
    if (!timeline || releases.length === 0) return; // Keep hardcoded fallback

    const fallback = currentLang === 'zh' ? 'Bug 修复和改进' : 'Bug fixes and improvements';
    const top5 = releases.slice(0, 5);
    timeline.innerHTML = top5.map((rel, i) => {
        const isLatest = i === 0;
        const desc = parseReleaseBody(rel.body) || fallback;
        const date = formatReleaseDate(rel.published_at);
        const tag = escapeHtml(rel.tag_name || '');
        const safeDesc = escapeHtml(desc);
        return `
            <div class="timeline-item">
                <div class="timeline-dot${isLatest ? ' latest' : ''}"></div>
                <div class="timeline-content">
                    <div class="timeline-header">
                        <span class="version-badge${isLatest ? ' latest' : ''}">${tag}</span>
                        <span class="timeline-date">${date}</span>
                    </div>
                    <p>${safeDesc}</p>
                </div>
            </div>
        `;
    }).join('');
}

// Update the hero eyebrow with the latest release version
async function updateHeroVersion() {
    const releases = await fetchReleases();
    if (releases.length === 0) return;
    const latest = releases[0];
    const eyebrow = document.querySelector('.hero-eyebrow [data-i18n="hero.eyebrow"]');
    if (!eyebrow) return;
    const tag = latest.tag_name || '';
    const isZh = currentLang === 'zh';
    const status = isZh ? '已发布' : 'released';
    eyebrow.textContent = `${tag} · ${status}`;
}

// ===== Scroll-reveal (IntersectionObserver) =====
// 整组触发：每个 section/grid 内的 reveal 元素用同一个观察者 callback
// 只要"任一"组内元素进入视口，整组同时显示（组内由 CSS :nth-child 控制微 stagger）
// 解决了"每个元素单独 IO 异步触发"导致组内元素延迟 16~48ms 不齐的问题
function initReveal() {
    const items = document.querySelectorAll('.reveal');
    if (!items.length || !('IntersectionObserver' in window)) {
        items.forEach(el => el.classList.add('is-visible'));
        return;
    }

    // 按"最近 grid/row 祖先"分组（找不到就单独成组）
    const groupOf = new WeakMap();
    const groups = new Map(); // key: groupKey -> [els]
    items.forEach(el => {
        const group = el.closest('.preview-grid, .features-grid, .download-steps, .hero-actions, .hero-badges, .changelog-list, .nav-actions')
            || el.parentElement;
        if (!groupOf.has(group)) groupOf.set(group, group);
        const key = groupOf.get(group);
        if (!groups.has(key)) groups.set(key, []);
        groups.get(key).push(el);
    });

    // 给每组加 is-revealing 旗标，让 CSS 用 :nth-child 计算组内微 stagger
    groups.forEach((els) => {
        els.forEach((el, i) => {
            el.style.setProperty('--reveal-stagger', String(i));
        });
    });

    // 记录已触发的组，用于实现组间延迟
    const revealedGroups = new Set();
    const GROUP_DELAY = 120; // 组间延迟 120ms

    const io = new IntersectionObserver((entries) => {
        // 按 group 聚合：任一元素进入视口时整组触发
        const groupsToReveal = new Set();
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const el = entry.target;
                const group = el.closest('.preview-grid, .features-grid, .download-steps, .hero-actions, .hero-badges, .changelog-list, .nav-actions')
                    || el.parentElement;
                groupsToReveal.add(group);
            }
        });

        // 按顺序触发组，组间添加延迟
        let delay = 0;
        groupsToReveal.forEach(group => {
            if (revealedGroups.has(group)) return;
            revealedGroups.add(group);

            const els = groups.get(group);
            if (!els) return;

            // 组内元素同时出现
            setTimeout(() => {
                requestAnimationFrame(() => {
                    els.forEach(el => el.classList.add('is-visible'));
                });
                // 整组都取消观察
                els.forEach(el => io.unobserve(el));
            }, delay);

            delay += GROUP_DELAY; // 组间延迟
        });
    }, { threshold: 0.05, rootMargin: '0px 0px -8% 0px' });
    items.forEach(el => io.observe(el));
}

// ===== Preview 图片淡入（解码完成后才显形，避免位图“啪”地闪出来） =====
// ===== Live Demo: 模拟 CursorTip 提示框触发 =====
function initLiveDemo() {
    const demos = document.querySelectorAll('.preview-demo');
    if (!demos.length) return;

    // 把 tip 锚定到光标/选区结束位置的右下方（贴近 cursor + offset）
    const positionTip = (demo) => {
        const tip = demo.querySelector('.demo-tip');
        const input = demo.querySelector('.demo-input');
        if (!tip || !input) return;
        const scene = demo.querySelector('.demo-scene');
        const sr = scene.getBoundingClientRect();
        const mouse = demo.querySelector('.demo-mouse');
        let mx, my;
        if (mouse) {
            const mr = mouse.getBoundingClientRect();
            mx = mr.left + mr.width / 2;
            my = mr.top + mr.height / 2;
        } else {
            const ir = input.getBoundingClientRect();
            mx = ir.right;
            my = ir.bottom;
        }
        const mouseEl = demo.querySelector('.demo-mouse');
        const mr = mouseEl.getBoundingClientRect();
        const ir = input.getBoundingClientRect();
        const dx = mr.right - sr.left + 4;
        const dy = ir.bottom - sr.top + 6;
        tip.style.left = dx + 'px';
        tip.style.top = dy + 'px';
    };

    const positionAll = () => {
        demos.forEach(positionTip);
    };
    positionAll();
    window.addEventListener('resize', positionAll);

    const SHOW_MS = 1000;
    const CYCLE_MS = 2000;

    const stateSeq = {
        caps: [
            { state: 'caps',  i18n: 'demo.caps.capsEn' },
            { state: 'caps',  i18n: 'demo.caps.capsCn' },
            { state: 'lower', i18n: 'demo.caps.lowerEn' },
            { state: 'lower', i18n: 'demo.caps.lowerCn' }
        ],
        copy: [
            { state: null, i18n: 'demo.copy.text' }
        ]
    };

    const setState = (tip, item) => {
        if (item.state) {
            tip.setAttribute('data-state', item.state);
        } else {
            tip.removeAttribute('data-state');
        }
        const textEl = tip.querySelector('.demo-tip-text');
        if (textEl && item.i18n) {
            const dict = (typeof i18n !== 'undefined' && i18n[currentLang]) ? i18n[currentLang] : null;
            textEl.textContent = (dict && dict[item.i18n]) ? dict[item.i18n] : item.i18n;
        }
    };

    const trigger = (scene, item) => {
        const tip = scene.querySelector('.demo-tip');
        if (!tip) return;
        if (item) setState(tip, item);
        tip.hidden = false;
        void tip.offsetWidth;
        tip.classList.add('is-visible');
    };

    const dismiss = (scene) => {
        const tip = scene.querySelector('.demo-tip');
        if (!tip) return;
        tip.classList.remove('is-visible');
        setTimeout(() => { tip.hidden = true; }, 100);
    };

    // 按类型分组，同步运行
    const demoGroups = {
        caps: [],
        copy: []
    };

    demos.forEach(demo => {
        const type = demo.dataset.demo;
        if (demoGroups[type]) {
            demoGroups[type].push(demo);
        }
    });

    // 为每组创建同步的定时器
    Object.keys(demoGroups).forEach(type => {
        const group = demoGroups[type];
        if (!group.length) return;

        const seq = stateSeq[type] || stateSeq.copy;

        // 如果只有一个状态，只显示一次，不循环
        if (seq.length === 1) {
            setTimeout(() => {
                group.forEach(scene => trigger(scene, seq[0]));
            }, 600);
            return;
        }

        let idx = 0;

        const show = () => {
            const item = seq[idx % seq.length];
            group.forEach(scene => trigger(scene, item));
            idx++;
            setTimeout(() => {
                group.forEach(scene => dismiss(scene));
            }, SHOW_MS);
            setTimeout(show, CYCLE_MS);
        };

        setTimeout(show, 600);
    });
}
function initPreviewImages() {
    const imgs = document.querySelectorAll('.preview-images img');
    imgs.forEach(img => {
        const reveal = () => img.classList.add('is-loaded');
        if (img.complete && img.naturalWidth > 0) {
            // 已缓存命中：下一帧再加 class，让 transition 生效
            requestAnimationFrame(reveal);
        } else {
            img.addEventListener('load', reveal, { once: true });
            img.addEventListener('error', reveal, { once: true });
        }
    });
}

// ===== Nav scroll state =====
function initNavScroll() {
    const nav = document.querySelector('.nav');
    if (!nav) return;
    const onScroll = () => {
        nav.classList.toggle('scrolled', window.scrollY > 24);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
}

// ===== Feature card mouse tracking (radial glow follow) =====
function initFeatureGlow() {
    const cards = document.querySelectorAll('.feature-card');
    cards.forEach(card => {
        card.addEventListener('pointermove', (e) => {
            const r = card.getBoundingClientRect();
            card.style.setProperty('--mx', `${e.clientX - r.left}px`);
            card.style.setProperty('--my', `${e.clientY - r.top}px`);
        });
    });
}

// Init
// ===== Smooth scroll (Lenis) =====
// 使用 RAF + lerp 接管页面滚动；遵循 prefers-reduced-motion，无障碍用户走原生滚动
function initSmoothScroll() {
    if (typeof Lenis === 'undefined') return;
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    const lenis = new Lenis({
        autoRaf: true,            // 内置 requestAnimationFrame 循环
        anchors: {                // 接管所有 a[href^="#"] 锚点
            offset: -88,          // 抵消固定导航栏高度
        },
        lerp: 0.1,                // 平滑系数，越大越紧跟手指/滚轮
        duration: 1.05,           // 滚动惯性时长（秒）
        easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        smoothWheel: true,
        touchMultiplier: 1.4,     // 触屏惯性灵敏度
    });

    // 滚动时同步 nav 阴影状态（替换原 scroll 监听以避免双重触发）
    const nav = document.querySelector('.nav');
    if (nav) {
        lenis.on('scroll', ({ scroll }) => {
            nav.classList.toggle('scrolled', scroll > 24);
        });
    }

    window.lenis = lenis;         // 暴露给调试和潜在外部调用
}

document.addEventListener('DOMContentLoaded', () => {
    applyLang(currentLang);
    initReveal();
    initNavScroll();
    initFeatureGlow();
    initPreviewImages();
    initLiveDemo();
    initSmoothScroll();

    // Dynamic content from GitHub Releases (non-blocking, with hardcoded fallback)
    Promise.all([updateHeroVersion(), renderChangelog()])
        .catch(err => console.warn('[CursorTip] Dynamic content failed:', err));
});
