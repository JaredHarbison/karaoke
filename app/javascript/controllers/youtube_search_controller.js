import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "urlField", "titleField", "searchBtn"]
  
  connect() {
    // Initialize abort controller for fetch requests
    this._abortController = new AbortController()
  }
  
  disconnect() {
    // Abort any pending fetch requests
    if (this._abortController) {
      this._abortController.abort()
      this._abortController = null
    }
    
    // Clean up the listener when the controller is removed
    this.removeResultsListener()
  }
  
  removeResultsListener() {
    if (this._resultsListener && this.hasResultsTarget) {
      this.resultsTarget.removeEventListener('click', this._resultsListener)
      this._resultsListener = null
    }
  }
  
  attachResultsListener() {
    // Remove any existing listener first
    this.removeResultsListener()
    
    if (!this.hasResultsTarget) return
    
    // Create click handler scoped to this instance
    this._resultsListener = (event) => {
      const button = event.target.closest('.result-select-btn')
      if (button) {
        this.selectVideo(button)
      }
    }
    
    this.resultsTarget.addEventListener('click', this._resultsListener)
  }
  
  getVenueSlug() {
    return this.element.dataset.youtubeSearchVenueSlug
  }
  
  getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  }
  
  async search(event) {
    event.preventDefault()
    
    // Abort any previous search requests
    if (this._abortController) {
      this._abortController.abort()
    }
    // Create a new abort controller for this search
    this._abortController = new AbortController()
    
    const query = this.queryTarget.value.trim()
    if (!query) {
      this.resultsTarget.innerHTML = '<p class="text-muted">Please enter a search term</p>'
      return
    }
    
    const venueSlug = this.getVenueSlug()
    if (!venueSlug) {
      this.resultsTarget.innerHTML = '<p class="error-message">❌ Venue not found</p>'
      return
    }
    
    // Disable search button to prevent multiple submissions
    if (this.hasSearchBtnTarget) {
      this.searchBtnTarget.disabled = true
      this.searchBtnTarget.textContent = 'Searching...'
    }
    
    this.resultsTarget.innerHTML = '<p class="text-muted">🔍 Searching YouTube...</p>'
    
    try {
      const response = await fetch(`/${venueSlug}/songs/youtube_search?query=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': this.getCsrfToken()
        },
        signal: this._abortController.signal
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      
      if (data.error) {
        this.resultsTarget.innerHTML = `<p class="error-message">❌ Error: ${data.error}</p>`
        return
      }
      
      this.displayResults(data.items)
    } catch (error) {
      // Don't show error if the request was aborted (user started a new search)
      if (error.name !== 'AbortError') {
        console.error('Search error:', error)
        this.resultsTarget.innerHTML = `<p class="error-message">❌ Failed to search YouTube</p>`
      }
    } finally {
      // Re-enable search button
      if (this.hasSearchBtnTarget) {
        this.searchBtnTarget.disabled = false
        this.searchBtnTarget.textContent = 'Search'
      }
    }
  }
  
  displayResults(items) {
    if (!items || items.length === 0) {
      this.resultsTarget.innerHTML = '<p class="text-muted">📭 No results found. Try a different search.</p>'
      return
    }
    
    try {
      // Build a single HTML string
      let html = ''
      for (let i = 0; i < items.length; i++) {
        const item = items[i]
        
        // Safety checks on item properties
        if (!item.title || !item.url) continue
        
        const title = this.decodeHtml(String(item.title)).substring(0, 100)
        const channel = this.decodeHtml(String(item.channel || 'Unknown')).substring(0, 50)
        const url = String(item.url)
        const thumb = item.thumbnail ? String(item.thumbnail) : 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
        
        html += '<div class="youtube-result-item"><div class="result-thumbnail"><img src="' + this.escapeHtml(thumb) + '" alt="" loading="lazy" /></div>'
        html += '<div class="result-details"><h5 class="result-title">' + this.escapeHtml(title) + '</h5>'
        html += '<p class="result-channel">YouTube · ' + this.escapeHtml(channel) + '</p>'
        html += '</div>'
        html += '<button type="button" class="result-select-btn" data-video-url="' + this.escapeHtml(url) + '" data-video-title="' + this.escapeHtml(title) + '"><span aria-hidden="true">▶</span><span>Select video</span></button>'
        html += '</div>'
      }
      
      // Set content once
      if (this.hasResultsTarget) {
        this.resultsTarget.innerHTML = html
        this.attachResultsListener()
      }
    } catch (error) {
      console.error('Error displaying results:', error)
      this.resultsTarget.innerHTML = '<p class="error-message">Error displaying results</p>'
    }
  }
  
  selectVideo(button) {
    const url = button.dataset.videoUrl
    if (!url) return

    // Set the URL field
    const urlInput = document.getElementById('song_url')
    if (urlInput) {
      urlInput.value = url

      const titleInput = this.hasTitleFieldTarget ? this.titleFieldTarget : document.getElementById('song_title')
      if (titleInput) {
        titleInput.value = button.dataset.videoTitle || ''
      }

      // Auto-submit the form after a brief delay to ensure value is set
      setTimeout(() => {
        const form = urlInput.closest('form')
        if (form) {
          form.submit()
        }
      }, 50)
    }
  }
  
  escapeHtml(text) {
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    }
    return String(text).replace(/[&<>"']/g, m => map[m])
  }

  decodeHtml(text) {
    const textarea = document.createElement('textarea')
    textarea.innerHTML = text
    return textarea.value
  }
}
