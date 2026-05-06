import hljs from 'highlight.js/lib/core'
import bash from 'highlight.js/lib/languages/bash'
import powershell from 'highlight.js/lib/languages/powershell'
import javascript from 'highlight.js/lib/languages/javascript'
import xml from 'highlight.js/lib/languages/xml'
import python from 'highlight.js/lib/languages/python'
import php from 'highlight.js/lib/languages/php'
import go from 'highlight.js/lib/languages/go'
import java from 'highlight.js/lib/languages/java'
import csharp from 'highlight.js/lib/languages/csharp'
import ruby from 'highlight.js/lib/languages/ruby'
import kotlin from 'highlight.js/lib/languages/kotlin'
import dart from 'highlight.js/lib/languages/dart'
import rust from 'highlight.js/lib/languages/rust'
import swift from 'highlight.js/lib/languages/swift'

hljs.registerLanguage('bash', bash)
hljs.registerLanguage('powershell', powershell)
hljs.registerLanguage('javascript', javascript)
hljs.registerLanguage('xml', xml)
hljs.registerLanguage('python', python)
hljs.registerLanguage('php', php)
hljs.registerLanguage('go', go)
hljs.registerLanguage('java', java)
hljs.registerLanguage('csharp', csharp)
hljs.registerLanguage('ruby', ruby)
hljs.registerLanguage('kotlin', kotlin)
hljs.registerLanguage('dart', dart)
hljs.registerLanguage('rust', rust)
hljs.registerLanguage('swift', swift)

/** 与 apiUseCardCodeExamples.js 中各条目的 id 对应 */
const EXAMPLE_ID_TO_LANG = {
  curl: 'bash',
  'curl-post-form': 'bash',
  wget: 'bash',
  httpie: 'bash',
  powershell: 'powershell',
  'node-fetch': 'javascript',
  'node-axios': 'javascript',
  'browser-js': 'javascript',
  html: 'xml',
  vue3: 'xml',
  'python-requests': 'python',
  'python-urllib': 'python',
  php: 'php',
  go: 'go',
  java: 'java',
  csharp: 'csharp',
  ruby: 'ruby',
  kotlin: 'kotlin',
  dart: 'dart',
  rust: 'rust',
  swift: 'swift'
}

/**
 * @param {string} code
 * @param {string} exampleId
 * @returns {string} 已转义并由 highlight.js 生成的 HTML
 */
export function highlightUseCardExample(code, exampleId) {
  if (!code) return ''
  const lang = EXAMPLE_ID_TO_LANG[exampleId] || 'bash'
  try {
    return hljs.highlight(code, { language: lang, ignoreIllegals: true }).value
  } catch {
    try {
      return hljs.highlightAuto(code).value
    } catch {
      return escapeHtml(code)
    }
  }
}

function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}
