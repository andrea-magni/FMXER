import { defineConfig } from 'vitepress'
import fs from 'node:fs'
import path from 'node:path'

// public address of the site (GitHub Pages): sitemap, canonical URLs, llms.txt
const SITE_URL = 'https://andrea-magni.github.io/FMXER/'
const SITE_DESCRIPTION = 'FMXER: a declarative, Flutter-inspired visual framework for Delphi FireMonkey (FMX). Build screens by composing frames and forms in code, with named routes, a scaffold, layout containers and ready-made elements.'

// sections of llms.txt, in the order of the sidebar
const LLMS_SECTIONS: [string, string][] = [
  ['Guide', 'guide/'],
  ['Elements', 'elements/'],
  ['Reference', 'reference/'],
  ['Demos', 'demos/'],
]
const LLMS_EXTRA = ['release-notes.md']

function splitFrontmatter(md: string): { data: Record<string, string>, body: string } {
  const data: Record<string, string> = {}
  const m = md.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n/)
  if (!m) return { data, body: md }
  for (const line of m[1].split(/\r?\n/)) {
    const kv = line.match(/^(\w+):\s*(.*)$/)
    if (kv) data[kv[1]] = kv[2].replace(/^['"]|['"]$/g, '')
  }
  return { data, body: md.slice(m[0].length) }
}

// title (first "# " heading) and description (frontmatter, or the first paragraph as plain text)
function pageSummary(md: string): { title: string, description: string } {
  const { data, body } = splitFrontmatter(md)
  const title = data.title || (body.match(/^#\s+(.+)$/m)?.[1] ?? '').trim()
  let description = data.description || ''
  if (!description) {
    const para = body.split(/\r?\n\s*\r?\n/).map(b => b.trim())
      .find(b => b && !/^(#|```|:::|\||<|-\s|\d+\.\s|!\[|\[\[)/.test(b))
    description = (para ?? '')
      .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
      .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
      .replace(/[`*_]/g, '')
      .replace(/\s+/g, ' ')
      .trim()
  }
  if (description.length > 300) description = description.slice(0, 297).replace(/\s+\S*$/, '') + '...'
  return { title, description }
}

function pageUrl(relativePath: string): string {
  return SITE_URL + relativePath.replace(/(^|\/)index\.md$/, '$1').replace(/\.md$/, '')
}

const guideSidebar = [
  {
    text: 'Getting Started',
    items: [
      { text: 'Introduction', link: '/guide/introduction' },
      { text: 'Installation', link: '/guide/installation' },
      { text: 'Your First App', link: '/guide/getting-started' },
      { text: 'Core Concepts', link: '/guide/core-concepts' },
    ],
  },
  {
    text: 'Building UIs',
    items: [
      { text: 'Composing Layouts', link: '/guide/layouts' },
      { text: 'Navigation', link: '/guide/navigation' },
      { text: 'Styling & Theming', link: '/guide/styling' },
      { text: 'State & Events', link: '/guide/state' },
      { text: 'Writing Your Own Elements', link: '/guide/custom-elements' },
      { text: 'FAQ & Troubleshooting', link: '/guide/faq' },
      { text: 'Building & Testing', link: '/guide/building' },
    ],
  },
]

const elementsSidebar = [
  {
    text: 'Elements',
    items: [
      { text: 'Catalog', link: '/elements/' },
      { text: 'Scaffold', link: '/elements/scaffold' },
      { text: 'Containers', link: '/elements/containers' },
      { text: 'Text & Input', link: '/elements/text-and-input' },
      { text: 'Images & Media', link: '/elements/images-and-media' },
      { text: 'Lists', link: '/elements/lists' },
      { text: 'QR Codes', link: '/elements/qrcode' },
      { text: 'Icons', link: '/elements/icons' },
    ],
  },
]

const referenceSidebar = [
  {
    text: 'Reference',
    items: [
      { text: 'TNavigator', link: '/reference/navigator' },
      { text: 'FMXER.UI.Misc', link: '/reference/ui-misc' },
      { text: 'TAppColors', link: '/reference/app-colors' },
      { text: 'Units & Dependencies', link: '/reference/units' },
    ],
  },
]

// FMXER documentation site configuration
export default defineConfig({
  base: '/FMXER/',
  title: 'FMXER',
  description: SITE_DESCRIPTION,
  lang: 'en-US',
  lastUpdated: true,
  cleanUrls: true,
  ignoreDeadLinks: false,

  // Internal maintenance docs that should not be part of the published site.
  srcExclude: ['REGEN.md', 'ANALYSIS.md'],

  sitemap: {
    hostname: SITE_URL,
  },

  head: [
    ['link', { rel: 'icon', href: '/FMXER/logo.png' }],
    ['meta', { name: 'theme-color', content: '#ff8f00' }],
    ['meta', { name: 'keywords', content: 'Delphi, Object Pascal, FireMonkey, FMX, FMXER, declarative UI, Flutter, TFrameStand, TFormStand, navigation, routes, scaffold, Skia, Android, iOS, macOS, Windows' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'FMXER' }],
    ['meta', { property: 'og:image', content: SITE_URL + 'logo.png' }],
    ['meta', { name: 'twitter:card', content: 'summary' }],
    ['link', { rel: 'alternate', type: 'text/plain', title: 'llms.txt', href: SITE_URL + 'llms.txt' }],
  ],

  // pages without a description in the frontmatter: the first paragraph (meta description)
  transformPageData(pageData, { siteConfig }) {
    if (!pageData.frontmatter.description && pageData.relativePath) {
      const file = path.join(siteConfig.srcDir, pageData.relativePath)
      if (fs.existsSync(file)) {
        const { description } = pageSummary(fs.readFileSync(file, 'utf-8'))
        if (description) pageData.description = description
      }
    }
  },

  // canonical URL and Open Graph / Twitter tags of every page
  transformHead({ pageData, title, description }) {
    const url = pageUrl(pageData.relativePath)
    return [
      ['link', { rel: 'canonical', href: url }],
      ['meta', { property: 'og:url', content: url }],
      ['meta', { property: 'og:title', content: title }],
      ['meta', { property: 'og:description', content: description }],
      ['meta', { name: 'twitter:title', content: title }],
      ['meta', { name: 'twitter:description', content: description }],
    ]
  },

  // llms.txt (index of the pages, https://llmstxt.org), llms-full.txt (all the pages in one file)
  // and a plain markdown copy of every page next to its HTML
  buildEnd(siteConfig) {
    const pages = siteConfig.pages.filter(p => LLMS_SECTIONS.some(([, prefix]) => p.startsWith(prefix)) || LLMS_EXTRA.includes(p))
    const read = (p: string) => fs.readFileSync(path.join(siteConfig.srcDir, p), 'utf-8')
    const order = (p: string) => { const i = LLMS_SECTIONS.findIndex(([, prefix]) => p.startsWith(prefix)); return i < 0 ? 99 : i }
    // pages in the order of the sidebar
    const sidebarLinks: string[] = []
    const collect = (items: any[]) => items?.forEach(item => {
      if (item.link) sidebarLinks.push(item.link.replace(/^\//, '').replace(/\/$/, '/index') + '.md')
      if (item.items) collect(item.items)
    })
    Object.values(siteConfig.site.themeConfig.sidebar ?? {}).forEach(groups => collect(groups as any[]))
    const rank = (p: string) => { const i = sidebarLinks.indexOf(p); return i < 0 ? Number.MAX_SAFE_INTEGER : i }
    const header = `# FMXER\n\n> ${SITE_DESCRIPTION}\n\n`
      + 'FMXER is an open source (MPL 2.0) framework for Embarcadero Delphi FireMonkey, built on TFrameStand and TFormStand. '
      + 'Source code, releases and demos: https://github.com/andrea-magni/FMXER\n'
    let index = header
    let full = header
    const sections = [...LLMS_SECTIONS.map(([name]) => name), 'More']
    for (const [i, name] of sections.entries()) {
      const inSection = pages.filter(p => order(p) === (i < LLMS_SECTIONS.length ? i : 99))
        .sort((a, b) => rank(a) - rank(b) || a.localeCompare(b))
      if (!inSection.length) continue
      index += `\n## ${name}\n\n`
      for (const p of inSection) {
        const md = read(p)
        const { title, description } = pageSummary(md)
        const mdUrl = pageUrl(p).replace(/\/$/, '/index') + '.md'
        index += `- [${title}](${mdUrl})${description ? ': ' + description : ''}\n`
        const body = splitFrontmatter(md).body
        full += `\n\n---\n\nSource: ${pageUrl(p)}\n\n${body.trim()}\n`
        const out = path.join(siteConfig.outDir, p)
        fs.mkdirSync(path.dirname(out), { recursive: true })
        fs.writeFileSync(out, body)
      }
    }
    fs.writeFileSync(path.join(siteConfig.outDir, 'llms.txt'), index)
    fs.writeFileSync(path.join(siteConfig.outDir, 'llms-full.txt'), full)
  },

  themeConfig: {
    logo: '/logo.png',

    nav: [
      { text: 'Guide', link: '/guide/introduction' },
      { text: 'Elements', link: '/elements/' },
      { text: 'Reference', link: '/reference/navigator' },
      { text: 'Demos', link: '/demos/' },
      { text: 'Release Notes', link: '/release-notes' },
      {
        text: 'Links',
        items: [
          { text: 'GitHub', link: 'https://github.com/andrea-magni/FMXER' },
          { text: 'Latest release', link: 'https://github.com/andrea-magni/FMXER/releases/latest' },
          { text: 'TFrameStand documentation', link: 'https://andrea-magni.github.io/TFrameStand/' },
          { text: 'CodeRage 2019: Introducing FMXER (video)', link: 'https://youtu.be/RiK2re19Kyk' },
          { text: "Author's site", link: 'https://www.andreamagni.eu' },
        ],
      },
    ],

    sidebar: {
      '/guide/': guideSidebar,
      '/elements/': elementsSidebar,
      '/reference/': referenceSidebar,
      '/demos/': [
        {
          text: 'Demos',
          items: [
            { text: 'Overview', link: '/demos/' },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/andrea-magni/FMXER' },
    ],

    editLink: {
      pattern: 'https://github.com/andrea-magni/FMXER/edit/master/docs/:path',
      text: 'Edit this page on GitHub',
    },

    search: {
      provider: 'local',
    },

    footer: {
      message: 'Released under the Mozilla Public License 2.0.',
      copyright: 'Copyright © 2019-present Andrea Magni',
    },
  },
})
