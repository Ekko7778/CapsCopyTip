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
        'preview.eyebrow': '效果展示',
        'preview.title': '效果预览',
        'preview.subtitle': '深色 / 浅色主题，跟随你的系统偏好',
        'preview.caps': '大小写 + 输入法提示',
        'preview.copy': '复制提示',
        'preview.settings': '设置界面',
        'download.eyebrow': '开始使用',
        'download.title': '获取 CursorTip',
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
        'changelog.v1.0.6': '内置光标指示器，添加应用图标和显示中/英状态开关',
        'changelog.v1.0.4': '浅色模式、顶部/底部偏移设置、光标语言标记',
        'changelog.v1.0.0': '初始版本：大小写提示、输入法状态、复制反馈',
        'changelog.viewAll': '查看全部版本',
        'footer.releases': 'Releases',
        'footer.copy': '© 2026 CursorTip. 使用 ❤️ 和 AutoHotkey v2 构建。'
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
        'preview.settings': 'Settings',
        'download.eyebrow': 'GET STARTED',
        'download.title': 'Get CursorTip',
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
        'changelog.v1.0.6': 'Built-in cursor indicator, app icon, C/EN toggle',
        'changelog.v1.0.4': 'Light mode, top/bottom offset, cursor language marker',
        'changelog.v1.0.0': 'Initial release: CapsLock, IME status, copy feedback',
        'changelog.viewAll': 'View All Releases',
        'footer.releases': 'Releases',
        'footer.copy': '© 2026 CursorTip. Built with ❤️ and AutoHotkey v2.'
    }
};

let currentLang = localStorage.getItem('cursortip-lang') || 'zh';

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

// ===== Scroll-reveal (IntersectionObserver) =====
function initReveal() {
    const items = document.querySelectorAll('.reveal');
    if (!items.length || !('IntersectionObserver' in window)) {
        items.forEach(el => el.classList.add('is-visible'));
        return;
    }
    const io = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
                io.unobserve(entry.target);
            }
        });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    items.forEach(el => io.observe(el));
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
document.addEventListener('DOMContentLoaded', () => {
    applyLang(currentLang);
    initReveal();
    initNavScroll();
    initFeatureGlow();
});
