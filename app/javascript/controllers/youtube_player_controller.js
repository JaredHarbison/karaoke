import { Controller } from "@hotwired/stimulus"

const ENDED = 0

export default class extends Controller {
  static targets = ["closeButton", "mount", "overlay", "status", "title"]

  connect() {
    this.player = null
    this.playButton = null
    this.enteredFullscreen = false
  }

  disconnect() {
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
    this.finishUrl = event.params.finishUrl
    this.titleTarget.textContent = event.params.performer
    this.statusTarget.textContent = "Loading video…"
    this.overlayTarget.hidden = false
    this.closeButtonTarget.focus()

    // Fullscreen must be requested synchronously from the Play gesture.
    if (this.overlayTarget.requestFullscreen) {
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
            if (data === ENDED) this.complete()
          },
          onError: () => {
            this.statusTarget.textContent = "YouTube could not play this video."
          }
        }
      })
    } catch (_error) {
      this.statusTarget.textContent = "The YouTube player could not be loaded."
    }
  }

  async complete() {
    this.statusTarget.textContent = "Performance complete. Updating the queue…"

    try {
      const response = await fetch(this.finishUrl, {
        method: "PATCH",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      })

      if (!response.ok) throw new Error("Unable to finish performance")

      this.enteredFullscreen = false
      await this.exitFullscreen()
      window.location.reload()
    } catch (_error) {
      this.statusTarget.textContent = "The performance ended, but the queue could not be updated."
    }
  }

  async close() {
    this.enteredFullscreen = false
    this.destroyPlayer()
    await this.exitFullscreen()
    this.overlayTarget.hidden = true
    this.statusTarget.textContent = ""
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
