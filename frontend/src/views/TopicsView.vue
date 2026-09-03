<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import CourseCard from '../components/CourseCard.vue'
import ContentPagination from '../components/ContentPagination.vue'
import PageHero from '../components/PageHero.vue'
import ProgressBar from '../components/ProgressBar.vue'
import AppIcon from '../components/base/AppIcon.vue'
import { dataMode } from '../services/api/client'
import { useAuthStore } from '../stores/auth'
import { useCoursesStore } from '../stores/content/courses'
import { useThemesStore } from '../stores/content/themes'
import { useLearningStore } from '../stores/learning'

const route = useRoute()
const router = useRouter()
const store = useLearningStore()
const auth = useAuthStore()
const courseStore = useCoursesStore()
const themeStore = useThemesStore()
const { items: courses } = storeToRefs(courseStore)
const { items: themes, selected: selectedTheme } = storeToRefs(themeStore)
const query = ref(String(route.query.q || ''))
const category = ref(String(route.query.category || '全部主题'))
const level = ref(String(route.query.level || '全部难度'))
const duration = ref(String(route.query.duration || '全部时长'))
const mode = ref(String(route.query.mode || '全部方式'))
const sort = ref(String(route.query.sort || '综合排序'))
const categories = computed(() => dataMode === 'api'
  ? ['全部主题', ...themes.value.map((theme) => theme.title)]
  : ['全部主题', '大模型 LLM', 'AI Agent', '图像生成', '模型部署', '智能硬件', 'AI 安全'])
const pathSteps = computed(() => {
  return selectedTheme.value?.paths[0]?.stages || []
})
const categoryIcon = (title: string) => themes.value.find((item) => item.title === title)?.data.icon || 'layers'
const stageMeta = (stage: (typeof pathSteps.value)[number]) => {
  const count = typeof stage.unlockRule.countLabel === 'string' ? stage.unlockRule.countLabel : `${stage.contents.length} 项内容`
  const hours = typeof stage.unlockRule.hours === 'number' ? `${stage.unlockRule.hours} 小时` : '时长待配置'
  return `${count} · ${hours}`
}
const overallProgress = computed(() => {
  const values = Object.values(store.courseProgress)
  return values.length ? Math.round(values.reduce((total, value) => total + value, 0) / values.length) : 0
})
const accountDataReady = computed(() => dataMode === 'mock' || store.accountSyncState === 'synced')
const accountDataMessage = computed(() => {
  if (!auth.user) return '登录后查看学习进度与最近记录。'
  return store.accountSyncState === 'sync-error' ? '账号学习数据暂不可用。' : '正在同步账号学习数据…'
})
const recentCourses = computed(() => store.recentCourses
  .map((id) => courses.value.find((course) => course.id === id))
  .filter((course): course is NonNullable<typeof course> => !!course))

const filtered = computed(() => {
  const keyword = query.value.trim().toLowerCase()
  const result = courses.value.filter((course) =>
    (!keyword || `${course.title}${course.description}${course.category}`.toLowerCase().includes(keyword)) &&
    (category.value === '全部主题' || course.category === category.value) &&
    (level.value === '全部难度' || course.level === level.value) &&
    (duration.value === '全部时长' ||
      (duration.value === '0～2 小时' && (course.hours ?? Infinity) <= 2) ||
      (duration.value === '2～5 小时' && (course.hours ?? 0) > 2 && (course.hours ?? Infinity) <= 5) ||
      (duration.value === '5～10 小时' && (course.hours ?? 0) > 5 && (course.hours ?? Infinity) <= 10) ||
      (duration.value === '10 小时以上' && (course.hours ?? 0) > 10)) &&
    (mode.value === '全部方式' || course.mode === mode.value))
  return sort.value === '时长最短'
    ? [...result].sort((a, b) => (a.hours ?? Infinity) - (b.hours ?? Infinity))
    : sort.value === '学习人数'
      ? [...result].sort((a, b) => (b.learners ?? 0) - (a.learners ?? 0))
      : result
})

const loadThemeDetail = async () => {
  const theme = themes.value.find((item) => item.title === category.value) || themes.value[0]
  if (theme) await themeStore.detail(theme.slug)
}

onMounted(async () => {
  await Promise.all([courseStore.load(), themeStore.load()])
  await loadThemeDetail()
})

watch([query, category, level, duration, mode, sort], () => {
  const params: Record<string, string> = {}
  if (query.value) params.q = query.value
  if (category.value !== '全部主题') params.category = category.value
  if (level.value !== '全部难度') params.level = level.value
  if (duration.value !== '全部时长') params.duration = duration.value
  if (mode.value !== '全部方式') params.mode = mode.value
  if (sort.value !== '综合排序') params.sort = sort.value
  if (new URLSearchParams(params).toString() !== new URLSearchParams(route.query as Record<string, string>).toString()) router.push({ query: params })
})

watch(() => route.query, (params) => {
  query.value = String(params.q || '')
  category.value = String(params.category || '全部主题')
  level.value = String(params.level || '全部难度')
  duration.value = String(params.duration || '全部时长')
  mode.value = String(params.mode || '全部方式')
  sort.value = String(params.sort || '综合排序')
})

watch(category, () => { void loadThemeDetail() })

const reset = () => {
  query.value = ''
  category.value = '全部主题'
  level.value = '全部难度'
  duration.value = '全部时长'
  mode.value = '全部方式'
  sort.value = '综合排序'
}
const search = () => courseStore.load({ page: 1, keyword: query.value }, true)
</script>

<template>
  <div class="page-container">
    <PageHero title="学习主题" description="系统化学习 AI 核心主题，从理论到实践，掌握前沿技术，用 AI 能力创造属于你的作品。" visual-key="topicsHeroAssetId">
      <span class="hero-badge">AI 学习社区 · 一起成长</span>
      <form class="hero-search" role="search" @submit.prevent="search"><input v-model="query" aria-label="搜索课程" placeholder="搜索课程、主题或技能…" /><button class="button primary" type="submit">搜索</button></form>
    </PageHero>
    <div class="category-tabs" role="tablist" aria-label="课程主题分类">
      <button v-for="item in categories" :key="item" type="button" :class="{ active: category === item }" @click="category = item"><svg v-if="category === item" class="app-icon" width="20" height="20" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path fill="currentColor" d="M848 784a79.936 79.936 0 0 0-73.248 48h-152.384A111.68 111.68 0 0 0 544 741.216V608h192c52.928 0 96-43.072 96-96s-43.072-96-96-96H288c-52.928 0-96 43.072-96 96s43.072 96 96 96h192v133.216A111.616 111.616 0 0 0 401.632 832H249.248A79.936 79.936 0 0 0 96 864a80 80 0 0 0 153.248 32h161.984c18.048 37.696 56.256 64 100.768 64s82.72-26.304 100.768-64h161.984A79.936 79.936 0 0 0 928 864a80 80 0 0 0-80-80zM288 544a32.032 32.032 0 0 1 0-64h448a32.032 32.032 0 0 1 0 64H288z m224 352c-26.464 0-48-21.536-48-48S485.536 800 512 800s48 21.536 48 48S538.464 896 512 896z" /><path fill="currentColor" d="M272 736h91.488a32 32 0 1 0 0-64H272A176.192 176.192 0 0 1 96 496a175.04 175.04 0 0 1 148.48-173.888l19.04-2.976 6.24-18.24C305.248 197.472 402.592 128 512 128a256 256 0 0 1 242.208 172.896l6.272 18.24 19.04 2.976A175.04 175.04 0 0 1 928 496c0 97.024-78.976 176-176 176h-97.28a32 32 0 1 0 0 64h97.28c132.352 0 240-107.648 240-240a238.592 238.592 0 0 0-183.808-233.408 320.16 320.16 0 0 0-592.352 0A238.592 238.592 0 0 0 32 496C32 628.352 139.648 736 272 736z" /></svg><AppIcon v-else :name="item === '全部主题' ? 'layers' : categoryIcon(item)" />{{ item }}<small v-if="item !== '全部主题'">{{ themes.find((theme) => theme.title === item)?.data.courseCount || 0 }}</small></button>
    </div>
    <section class="learning-path"><div class="section-heading"><h2>{{ selectedTheme?.paths[0]?.name || '推荐学习路径' }}</h2><span>{{ selectedTheme?.paths[0]?.description || '从入门到实践，逐步掌握 AI 能力' }}</span><RouterLink to="/profile">查看完整路径 <AppIcon name="arrow-right" :size="15" /></RouterLink></div><div v-if="pathSteps.length" class="path-steps"><div v-for="(step, index) in pathSteps" :key="step.id" :class="{ done: accountDataReady && index < 2, current: accountDataReady && index === 2 }"><span>{{ String(index + 1).padStart(2, '0') }}</span><AppIcon :name="step.stageType === 'project' ? 'tool' : step.stageType === 'assessment' ? 'check' : 'layers'" /><strong>{{ step.name }}</strong><small>{{ stageMeta(step) }}</small></div></div><p v-else>该主题暂未发布学习路径。</p></section>
    <div class="catalog-layout">
      <aside class="filter-panel">
        <div class="panel-title"><strong>筛选条件</strong><button type="button" @click="reset">清空</button></div>
        <label>难度<select v-model="level"><option>全部难度</option><option>入门</option><option>初级</option><option>中级</option><option>高级</option></select></label>
        <label>学习时长<select v-model="duration"><option>全部时长</option><option>0～2 小时</option><option>2～5 小时</option><option>5～10 小时</option><option>10 小时以上</option></select></label>
        <label>学习方式<select v-model="mode"><option>全部方式</option><option>视频</option><option>图文</option><option>实战项目</option><option>互动实验</option></select></label>
        <button class="button secondary full-width" type="button" @click="reset">重置筛选</button>
      </aside>
      <section class="catalog-main">
        <div class="catalog-toolbar"><strong>全部课程 <small>共 {{ filtered.length }} 门课程</small></strong><select v-model="sort" aria-label="课程排序"><option>综合排序</option><option>时长最短</option><option>学习人数</option></select></div>
        <div v-if="filtered.length" class="card-grid three"><CourseCard v-for="course in filtered" :key="course.id" :course="course" /></div>
        <div v-else class="inline-empty"><h3>没有找到匹配课程</h3><p>试试清空筛选条件。</p><button class="button secondary" type="button" @click="reset">重置筛选</button></div>
        <ContentPagination :page="courseStore.page" :page-size="courseStore.pageSize" :total="courseStore.total" @change="courseStore.load({ page: $event, keyword: query })" />
      </section>
      <aside class="study-aside">
        <h3>我的学习进度</h3>
        <template v-if="accountDataReady">
          <div class="progress-ring"><strong>{{ overallProgress }}%</strong><span>总进度</span></div><ProgressBar :value="overallProgress" :label="dataMode === 'api' ? '账号课程进度' : '演示学习进度'" />
          <div class="mini-stats"><span><strong>{{ Object.keys(store.courseProgress).length }}</strong>已学课程</span><span><strong>{{ store.recentCourses.length }}</strong>最近学习</span><span><strong>{{ Object.values(store.courseProgress).filter((value) => value === 100).length }}</strong>已完成</span></div>
          <template v-if="dataMode === 'mock'"><h3>本周学习活跃度</h3><div class="activity-heatmap" aria-label="本周学习活跃度"><span v-for="index in 28" :key="index" :class="`level-${index % 5}`" :title="`学习强度 ${index % 5}`" /></div></template><p v-else>学习活跃度尚未提供个人聚合数据。</p>
          <h3>最近学习</h3><RouterLink v-for="course in recentCourses" :key="course.id" :to="`/courses/${course.id}`">{{ course.title }}<small>继续学习 <AppIcon name="arrow-right" :size="14" /></small></RouterLink><p v-if="!recentCourses.length">暂无学习记录。</p>
          <template v-if="dataMode === 'mock'"><h3>学习成就</h3><div class="mini-achievements"><span><strong><AppIcon name="achievement" :size="18" /></strong>连续学习 7 天</span><span><strong><AppIcon name="graduation" :size="18" /></strong>课程达人</span><span><strong><AppIcon name="tool" :size="18" /></strong>实验先锋</span></div></template><RouterLink to="/profile">查看全部成就 <AppIcon name="arrow-right" :size="15" /></RouterLink>
        </template>
        <p v-else class="notice">{{ accountDataMessage }}</p>
      </aside>
    </div>
    <section><div class="section-heading"><div><span class="eyebrow">个性推荐</span><h2>为你推荐</h2></div></div><div v-if="dataMode === 'mock'" class="recommendation-row"><CourseCard v-for="course in courses.slice(4, 9)" :key="course.id" :course="course" compact /></div><p v-else>个性化推荐尚未配置。</p></section>
  </div>
</template>
