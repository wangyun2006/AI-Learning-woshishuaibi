<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppIcon from '../components/base/AppIcon.vue'
import AppDialog from '../components/base/AppDialog.vue'
import CommunityAvatar from '../components/base/CommunityAvatar.vue'
import { communityArt } from '../assets/community/manifest'
import { useAuthStore } from '../stores/auth'
import { useCommunityStore } from '../stores/community'
import { communityApi } from '../services/api/community'
import { communityNavigation, communityNavActive } from '../community/labels'
import CommunityRightRail from '../community/CommunityRightRail.vue'
import CommunityPostMenu from '../community/CommunityPostMenu.vue'
import { provideCommunityScrollRoot } from '../community/composables/useCommunityScrollRoot'
const auth = useAuthStore(), store = useCommunityStore(), router = useRouter(), route = useRoute()
const collapsed = ref(false), menuOpen = ref(false)
const mainScroll = provideCommunityScrollRoot()
const wide = computed(() => route.meta.communityMode === 'wide')
const profileRoute = computed(() => `/community/user/${auth.user?.username}`)
const groups = [
  { label: '发现与学习', items: communityNavigation.filter((item) => !['/profile', '/bookmarks', '/notifications', '/community/drafts'].includes(item.path)) },
  { label: '个人', items: communityNavigation.filter((item) => ['/profile', '/bookmarks', '/notifications', '/community/drafts'].includes(item.path)) },
]
watch(collapsed, (value) => { try { localStorage.setItem('community-sidebar-collapsed', String(value)) } catch { /* 隐私模式仍可使用当前选择。 */ } })
let polling: number | undefined
const loadUnread = async () => { if (document.visibilityState !== 'visible') return; const epoch = store.epoch; try { const result = await communityApi.unread(); if (epoch === store.epoch) store.unread = result.count } catch { /* 内容区保留可重试错误，不中断正在阅读的页面。 */ } }
const logout = async () => { await auth.logout(); await router.replace('/') }
onMounted(() => { try { collapsed.value = localStorage.getItem('community-sidebar-collapsed') === 'true' } catch { /* 不要求浏览器允许持久存储。 */ }; void store.loadContext(auth.user?.id).catch((error: Error) => { store.error = error.message }); void loadUnread(); polling = window.setInterval(loadUnread, 60000) })
onBeforeUnmount(() => window.clearInterval(polling))
</script>
<template>
  <div class="community-shell" :class="{ 'sidebar-collapsed': collapsed, 'community-wide': wide }">
    <a class="skip-link" href="#main-content">跳到主要内容</a>
    <aside class="community-sidebar">
      <RouterLink class="brand community-brand" to="/community"><span class="brand-mark">A</span><span class="nav-label"><strong>AI MAKER CAMPUS</strong><small>高校 AI 创客学习平台</small></span></RouterLink>
      <button class="sidebar-collapse icon-button" type="button" :aria-label="collapsed ? '展开侧栏' : '收起侧栏'" @click="collapsed = !collapsed"><AppIcon name="menu" :size="20" /></button>
      <nav class="community-sidebar-nav" aria-label="学习社区导航"><section v-for="group in groups" :key="group.label" class="community-nav-group"><h2 class="nav-label">{{ group.label }}</h2><RouterLink v-for="item in group.items" :key="item.path" :to="item.path" :title="item.label" :class="{ active: communityNavActive(route.path, item.path) }" :aria-current="communityNavActive(route.path, item.path) ? 'page' : undefined"><AppIcon v-if="item.path !== '/topics' && item.path !== '/community' && item.path !== '/labs'" :name="item.icon" :size="21" /><svg v-else-if="item.path === '/labs'" class="app-icon" width="21" height="21" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path fill="currentColor" d="M602.112 172.8H282.88A134.4 134.4 0 0 0 148.48 307.2v409.6c0 74.24 60.16 134.4 134.4 134.4h490.624l1.024-64-4.3776-0.128c-18.4064-1.152-33.6384-17.3056-33.6384-36.864V307.2c0-74.24-60.16-134.4-134.4-134.4z m0 64A70.4 70.4 0 0 1 672.512 307.2v443.008l0.128 5.12c0.512 10.24 2.56 20.0448 5.888 29.2608l0.9984 2.6112H282.88A70.4 70.4 0 0 1 212.48 716.8V307.2a70.4 70.4 0 0 1 70.4-70.4h319.232z" /><path fill="currentColor" d="M874.2656 403.2v345.984a102.016 102.016 0 0 1-96.9216 101.888l-5.0944 0.128v-64c19.7632 0 36.0192-15.0784 37.8368-34.3552l0.1792-3.6608V467.2h-38.016v-64h102.016zM582.4 348.7744v64h-268.8v-64z" /><path fill="currentColor" d="M315.8016 479.9488h113.9712v206.464h-113.9712z" /><path fill="currentColor" d="M582.4 485.12v64h-102.4v-64zM582.4 621.4656v64h-102.4v-64z" /></svg><svg v-else-if="item.path === '/community'" class="app-icon" width="21" height="21" viewBox="0 0 1199 1024" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path fill="currentColor" d="M599.883366 36.485018 14.397338 622.032998l237.705 0 0 383.981 222.536 0c38.057984-82.68503 101.058048-151.528038 179.386982-196.925952-0.27095-17.363968-0.420966-36.896051-0.134963-62.398976-90.196992 44.91305-164.726989 116.515021-213.204992 204.47703L306.957344 951.166101 306.957344 567.178 143.639344 567.178l455.873024-455.873024L1055.391334 567.178035 892.074344 567.178035l0 383.989L745.790344 951.167035l0 54.848 201.139 0L946.929344 622.033l237.705 0L599.883366 36.485018z" /></svg><svg v-else class="app-icon" width="21" height="21" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path fill="currentColor" d="M996.087285 487.193252L557.600175 19.815769a62.655677 62.655677 0 0 0-91.443421 0L27.720959 487.193252a62.655677 62.655677 0 0 0 45.721711 105.606375h62.245157v314.715207a116.33122 116.33122 0 0 0 116.177275 116.228591h170.622544v-312.3034a21.398376 21.398376 0 0 1 21.347061-21.347061h136.087515a21.398376 21.398376 0 0 1 21.347061 21.347061v312.559975h170.622545a116.33122 116.33122 0 0 0 116.177275-116.22859v-314.971783h62.245157a62.706992 62.706992 0 0 0 45.773025-105.606375z m-182.425006 31.199551v389.122031a41.821766 41.821766 0 0 1-41.770451 41.821767h-96.215721v-237.896576a95.856515 95.856515 0 0 0-95.753885-95.753885H443.834707a95.856515 95.856515 0 0 0-95.753885 95.753885v238.153151H251.865102a41.821766 41.821766 0 0 1-41.770452-41.821766v-389.378607H100.434387l411.444078-438.58974 411.444078 438.58974z" /></svg><span class="nav-label">{{ item.label }}</span><b v-if="item.path === '/notifications' && store.unread" class="notification-count">{{ store.unread }}</b></RouterLink></section></nav>
      <button class="button primary community-publish" type="button" title="发布内容" @click="store.openComposer()"><AppIcon name="plus" :size="20" /><span class="nav-label">发布内容</span></button>
      <div class="community-account">
        <CommunityPostMenu label="账户菜单"><template #trigger><CommunityAvatar :src="auth.user?.avatarUrl" :username="auth.user?.username" :name="auth.user?.displayName || '学习者'" /><span class="nav-label"><strong>{{ auth.user?.displayName }}</strong><small>{{ auth.dataMode === 'mock' ? '显式演示模式' : '统一学习账号' }}</small></span><AppIcon class="nav-label account-more" name="more-circle" :size="18" /></template><RouterLink :to="profileRoute" role="menuitem">个人主页</RouterLink><RouterLink :to="`${profileRoute}?settings=1`" role="menuitem">账号设置</RouterLink><button type="button" role="menuitem" @click="logout">退出登录</button></CommunityPostMenu>
        <RouterLink class="text-link nav-label portal-link" to="/welcome">查看品牌门户 <AppIcon name="arrow-right" :size="14" /></RouterLink>
      </div>
      <img v-bind="communityArt.sidebarPlanet" class="sidebar-decoration" alt="" loading="lazy" />
    </aside>
    <header class="community-mobile-header"><RouterLink class="brand" to="/community"><span class="brand-mark">A</span><strong>AI MAKER CAMPUS</strong></RouterLink><button class="icon-button" aria-label="更多功能" @click="menuOpen = true"><AppIcon name="menu" /></button></header>
    <main id="main-content" ref="mainScroll" class="community-main" tabindex="-1"><slot /></main>
    <CommunityRightRail v-if="!wide" />
    <nav class="community-bottom-nav" aria-label="移动主导航"><RouterLink v-for="item in communityNavigation.filter((item) => item.mobile).sort((a, b) => a.mobileOrder - b.mobileOrder)" :key="item.path" :to="item.path" :class="{ active: communityNavActive(route.path, item.path) }" :style="{ order: item.mobileOrder }"><AppIcon :name="item.icon" :size="21" /><span>{{ item.label.replace('首页', '').replace('主题', '').replace('项目', '').replace('消息', '').replace('成长', '') }}</span></RouterLink><button class="mobile-publish-button" @click="store.openComposer()"><AppIcon name="plus" :size="24" /><span>发布</span></button></nav>
    <AppDialog v-model="menuOpen" title="学习社区"><nav class="community-more"><RouterLink v-for="item in communityNavigation" :key="item.path" :to="item.path" @click="menuOpen = false">{{ item.label }}</RouterLink><RouterLink to="/welcome" @click="menuOpen = false">品牌门户</RouterLink><button class="text-link" @click="logout">退出登录</button></nav></AppDialog>
    <button class="community-floating-publish" aria-label="快捷发布" @click="store.openComposer()"><AppIcon name="plus" /></button>
  </div>
</template>
