import { Controller } from "@hotwired/stimulus"

const ENDED = 0
const PLAYING = 1

export default class extends Controller {
  static targets = ["closeButton", "mount", "overlay", "presentationNextLabel", "presentationNextPerformer", "presentationNextTitle", "presentationSecondPerformer", "presentationSecondTitle", "status", "title"]

  connect() {
    this.player = null
    this.playButton = null
    this.enteredFullscreen = false
    this.playbackStarted = false
    this.completing = false
    this.playbackToken = 0
    this.handlePageHide = this.completeOnPageExit.bind(this)
    window.addEventListener("pagehide", this.handlePageHide)
  }

  disconnect() {
    this.playbackToken += 1
    window.removeEventListener("pagehide", this.handlePageHide)
    this.destroyPlayer()
  }

  async play(event) {
    event.preventDefault()

    const videoId = this.videoIdFrom(event.params.url)
    if (!videoId) {
      this.statusTarget.textContent = "This YouTube link cannot be played."
      return
    }

    this.playButton = event.currentTarget
    const playbackToken = ++this.playbackToken
    this.finishUrl = event.params.finishUrl
    this.startUrl = event.params.startUrl
    this.stopUrl = event.params.stopUrl
    this.startedOnServer = false
    this.startRequest = null
    this.playbackStarted = false
    this.completing = false
    this.titleTarget.textContent = event.params.performer
    this.statusTarget.textContent = "Loading video…"
    this.overlayTarget.hidden = false
    this.closeButtonTarget.focus()
    this.shiftQueueDisplay(event.params)
    this.startPerformance()

    // The presentation view has its own stage between the navbar and footer;
    // leave that layout visible while the performance plays. The queue player
    // still uses browser fullscreen.
    if (!this.isPresentationView() && this.overlayTarget.requestFullscreen) {
      this.overlayTarget.requestFullscreen()
        .then(() => { this.enteredFullscreen = true })
        .catch(() => { this.enteredFullscreen = false })
    }

    try {
      const YT = await this.loadYouTubeApi()
      this.destroyPlayer()
      const frame = document.createElement("div")
      this.mountTarget.appendChild(frame)
      this.player = new YT.Player(frame, {
        videoId,
        width: "100%",
        height: "100%",
        playerVars: {
          autoplay: 1,
          controls: 1,
          modestbranding: 1,
          playsinline: 0,
          rel: 0
        },
        events: {
          onReady: ({ target }) => {
            this.statusTarget.textContent = ""
            target.playVideo()
          },
          onStateChange: ({ data }) => {
            if (playbackToken !== this.playbackToken) return
            if (data === PLAYING) {
              this.playbackStarted = true
            }
            if (data === ENDED) this.complete()
          },
          onError: ({ data }) => {
            if (playbackToken !== this.playbackToken) return
            this.stopPerformance()
            this.restoreQueueDisplay()
            this.statusTarget.textContent = [101, 150].includes(data)
              ? "This video cannot play here because its owner disabled playback on other websites. Choose another YouTube video."
              : "YouTube could not play this video."
          }
        }
      })
    } catch (_error) {
      this.mountFallback(videoId)
    }
  }

  mountFallback(videoId) {
    this.destroyPlayer()
    const frame = document.createElement("iframe")
    frame.src = `https://www.youtube.com/embed/${encodeURIComponent(videoId)}?autoplay=1&controls=1&modestbranding=1&rel=0`
    frame.title = `${this.titleTarget.textContent} playback`
    frame.allow = "autoplay; encrypted-media; picture-in-picture"
    frame.allowFullscreen = true
    frame.referrerPolicy = "strict-origin-when-cross-origin"
    this.mountTarget.appendChild(frame)
    this.playbackStarted = true
    this.statusTarget.textContent = ""
  }

  async complete() {
    if (this.completing || !this.finishUrl) return

    this.completing = true
    this.statusTarget.textContent = "Performance complete. Updating the queue…"

    try {
      const response = await this.finishPerformance()

      if (!response.ok) throw new Error("Unable to finish performance")

      this.enteredFullscreen = false
      await this.exitFullscreen()
      window.location.reload()
    } catch (_error) {
      this.completing = false
      this.statusTarget.textContent = "The performance ended, but the queue could not be updated."
    }
  }

  async endAndAdvance() {
    this.playbackToken += 1
    this.destroyPlayer()
    await this.startRequest?.catch(() => {})
    this.complete()
  }

  async startPerformance() {
    if (this.startedOnServer || !this.startUrl) return

    this.startedOnServer = true
    this.startRequest = this.updatePerformance(this.startUrl)
      .then((response) => {
        if (!response.ok) throw new Error("Unable to start performance")
      })
      .catch((_error) => {
        this.startedOnServer = false
        this.statusTarget.textContent = "The video is playing, but the queue could not be updated."
      })
    return this.startRequest
  }

  completeOnPageExit() {
    if (!this.playbackStarted || this.completing || !this.finishUrl) return

    this.completing = true
    this.finishPerformance({ keepalive: true }).catch(() => {})
  }

  finishPerformance({ keepalive = false } = {}) {
    return this.updatePerformance(this.finishUrl, { keepalive })
  }

  stopPerformance() {
    return this.stopUrl ? this.updatePerformance(this.stopUrl) : Promise.resolve()
  }

  updatePerformance(url, { keepalive = false } = {}) {
    return fetch(url, {
      method: "PATCH",
      keepalive,
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
  }

  isPresentationView() {
    return this.overlayTarget.closest(".songs-page--presentation") != null
  }

  shiftQueueDisplay(params) {
    this.shiftMainQueueCard()
    this.shiftPresentationFooter(params)
  }

  shiftMainQueueCard() {
    const currentCard = this.playButton?.closest(".song-queue-card")
    const currentBadge = currentCard?.querySelector(".song-next-badge")
    const nextBadge = currentCard?.nextElementSibling?.querySelector(".song-position")

    if (!currentBadge) return

    this.mainQueueState = [currentBadge, nextBadge].filter(Boolean).map((element) => ({
      element,
      className: element.className,
      textContent: element.textContent
    }))

    currentBadge.className = "song-position"
    currentBadge.textContent = "Now"

    if (nextBadge) {
      nextBadge.className = "song-next-badge"
      nextBadge.textContent = "Up next"
    }
  }

  shiftPresentationFooter(params) {
    if (!this.hasPresentationNextPerformerTarget) return

    this.presentationQueueState = [
      this.presentationNextLabelTarget,
      this.presentationNextPerformerTarget,
      this.presentationNextTitleTarget,
      this.presentationSecondPerformerTarget,
      this.presentationSecondTitleTarget
    ].map((element) => ({ element, textContent: element.textContent }))

    this.presentationNextLabelTarget.textContent = "Up next"
    this.presentationNextPerformerTarget.textContent = params.upNextPerformer || "Nothing queued"
    this.presentationNextTitleTarget.textContent = params.upNextTitle || ""
    this.presentationSecondPerformerTarget.textContent = params.upSecondPerformer || "—"
    this.presentationSecondTitleTarget.textContent = params.upSecondTitle || ""
  }

  restoreQueueDisplay() {
    this.mainQueueState?.forEach(({ element, className, textContent }) => {
      element.className = className
      element.textContent = textContent
    })
    this.presentationQueueState?.forEach(({ element, textContent }) => {
      element.textContent = textContent
    })
    this.mainQueueState = null
    this.presentationQueueState = null
  }

  async close() {
    this.playbackToken += 1
    this.enteredFullscreen = false
    this.destroyPlayer()
    await this.startRequest?.catch(() => {})
    await this.stopPerformance()
    await this.exitFullscreen()
    this.overlayTarget.hidden = true
    this.statusTarget.textContent = ""
    this.restoreQueueDisplay()
    this.playButton?.focus()
  }

  fullscreenChanged() {
    if (this.enteredFullscreen && !document.fullscreenElement && !this.overlayTarget.hidden) {
      this.close()
    }
  }

  destroyPlayer() {
    if (this.player?.destroy) this.player.destroy()
    this.player = null
    this.mountTarget.replaceChildren()
  }

  async exitFullscreen() {
    if (document.fullscreenElement && document.exitFullscreen) {
      await document.exitFullscreen().catch(() => {})
    }
  }

  videoIdFrom(value) {
    try {
      const url = new URL(value)
      if (url.hostname.includes("youtu.be")) return url.pathname.slice(1)
      if (url.pathname.startsWith("/embed/")) return url.pathname.split("/")[2]
      return url.searchParams.get("v")
    } catch (_error) {
      return /^[a-zA-Z0-9_-]{11}$/.test(value) ? value : null
    }
  }

  loadYouTubeApi() {
    if (window.YT?.Player) return Promise.resolve(window.YT)
    if (window.youtubeApiPromise) return window.youtubeApiPromise

    window.youtubeApiPromise = new Promise((resolve, reject) => {
      const previousCallback = window.onYouTubeIframeAPIReady
      window.onYouTubeIframeAPIReady = () => {
        previousCallback?.()
        resolve(window.YT)
      }

      const script = document.createElement("script")
      script.src = "https://www.youtube.com/iframe_api"
      script.onerror = reject
      document.head.appendChild(script)
    })

    return window.youtubeApiPromise
  }
}
