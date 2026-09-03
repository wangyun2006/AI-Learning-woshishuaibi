<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import type { CommunityFeedMode, CommunityPostType } from '@ai-learning-hub/contracts'
import AppIcon from '../components/base/AppIcon.vue'
defineProps<{ mode: CommunityFeedMode; type: CommunityPostType | 'all'; newCount: number; loading: boolean }>()
defineEmits<{ change: [mode: CommunityFeedMode, type: CommunityPostType | 'all']; refresh: [] }>()
const router = useRouter()
const keyword = ref('')
const search = () => router.push('/community/search')
const submitSearch = () => {
  const q = keyword.value.trim()
  void router.push({ path: '/community/search', query: q ? { q } : {} })
}
const shortcut = (event: KeyboardEvent) => {
  const target = event.target as HTMLElement | null
  if (event.key !== '/' || event.ctrlKey || event.metaKey || event.altKey || target?.closest('input, textarea, select, [contenteditable="true"], dialog[open]')) return
  event.preventDefault()
  void search()
}
onMounted(() => window.addEventListener('keydown', shortcut))
onBeforeUnmount(() => window.removeEventListener('keydown', shortcut))
</script>
<template>
  <div class="community-feed-sticky">
    <div class="community-feed-mode-row">
      <div class="community-feed-tabs" role="tablist" aria-label="信息流模式"><button v-for="[value, label] in [['for_you', '推荐'], ['following', '关注'], ['latest', '最新']]" :key="value" class="featured-tab" role="tab" :aria-selected="mode === value" @click="$emit('change', value as CommunityFeedMode, type)">{{ label }}</button></div>
      <button class="icon-button" aria-label="刷新信息流" :disabled="loading" @click="$emit('refresh')"><svg class="app-icon" width="19" height="19" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path fill="#ff4d1f" d="M511.582491 63.413262C265.134543 63.413262 64.62588 263.921925 64.62588 510.369873s200.508663 446.957635 446.957635 446.957635 446.957635-200.508663 446.957635-446.957635S758.031463 63.413262 511.582491 63.413262zM509.001713 751.859903c-98.517781 0-182.467775-62.623269-214.771505-150.056598l0.327458-0.134053c-2.007727-4.036943-3.38305-8.422833-3.38305-13.237489 0-16.647145 13.494339-30.142507 30.142507-30.142507 13.389962 0 24.358781 8.877181 28.2893 20.955264l0.422625-0.172939c23.269983 65.442478 85.645612 112.503307 158.972665 112.503307 93.106538 0 168.845523-75.738985 168.845523-168.845523s-75.738985-168.845523-168.845523-168.845523c-20.432355 0-39.874149 3.980661-58.013275 10.66899l21.248953 40.742936c2.486634 2.677992 4.0175 6.2831 4.0175 10.243295 0 8.417717-8.404414 14.921851-15.365966 15.07023-0.102331 0-0.206708 0-0.309038 0-0.220011 0-0.427742 0-0.647753-0.013303l-150.579507-6.463202c-5.372358-0.234337-10.229992-3.310396-12.716626-8.093329-2.486634-4.76963-2.236947-10.509355 0.647753-15.055904l80.890308-127.179564c2.8847-4.533246 8.006348-7.151887 13.365402-6.960529 5.372358 0.234337 10.227945 3.312442 12.71458 8.095375l18.580171 35.625382c26.629497-10.855232 55.683207-16.963347 86.168522-16.963347 126.338407 0 229.130537 102.791108 229.130537 229.130537S635.340119 751.859903 509.001713 751.859903z" /></svg></button>
      <button class="icon-button search-icon-button" aria-label="搜索社区学习内容" title="搜索（/）" @click="search"><AppIcon name="search" :size="19" /></button>
    </div>
    <div class="community-filters" aria-label="内容类型"><button v-for="[value, label] in [['all', '全部'], ['question', '学习问答'], ['note', '学习笔记'], ['lab_result', '实训成果'], ['project', '创客项目'], ['frontier_discussion', '前沿讨论']]" :key="value" :class="{ active: type === value }" :aria-pressed="type === value" @click="$emit('change', mode, value as CommunityPostType | 'all')">{{ label }}</button><form class="community-search community-filters-search" @submit.prevent="submitSearch"><AppIcon name="search" :size="16" /><input v-model="keyword" type="search" placeholder="搜索动态、用户与话题" aria-label="搜索社区内容" maxlength="120" /><button type="submit" class="community-filters-search-go">搜索</button></form></div>
    <button v-if="newCount" class="community-new-content" :disabled="loading" @click="$emit('refresh')">有 {{ newCount }} 条新内容，点击加载</button>
  </div>
</template>
