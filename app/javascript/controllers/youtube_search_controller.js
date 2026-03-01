import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "urlField", "searchBtn"]
  
  connect() {
    // Initialize abort controller for fetch requests
    this._abortController = new AbortController()
    
    // Remove any previously attached listener to prevent duplicates
    if (this._boundClickHandler) {
      this.element.removeEventListener('click', this._boundClickHandler)
    }
    
    // Create and store the bound handler so we can reference it later
    this._boundClickHandler = this.handleResultClick.bind(this)
    this.element.addEventListener('click', this._boundClickHandler)
  }
  
  disconnect() {
    // Abort any pending fetch requests
    if (this._abortController) {
      this._abortController.abort()
      this._abortController = null
    }
    
    // Clean up the listener when the controller is removed
    if (this._boundClickHandler) {
      this.element.removeEventListener('click', this._boundClickHandler)
      this._boundClickHandler = null
    }
  }
  
  handleResultClick(event) {
    // Use event delegation on dynamically created buttons
    const button = event.target.closest('.result-select-btn')
    if (button) {
      this.selectVideo(button)
    }
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
    
    const resultsHtml = items.map(item => `
      <div class="youtube-result-item">
        <div class="result-thumbnail">
          <img src="${this.escapeHtml(item.thumbnail)}" alt="Video thumbnail" loading="lazy" />
        </div>
        <div class="result-details">
          <h5 class="result-title">${this.escapeHtml(item.title)}</h5>
          <p class="result-channel">${this.escapeHtml(item.channel)}</p>
          <button type="button" class="btn-small result-select-btn" data-video-url="${this.escapeHtml(item.url)}">
            ▶️ Select
          </button>
        </div>
      </div>
    `).join('')
    
    this.resultsTarget.innerHTML = resultsHtml
  }
  
  selectVideo(button) {
    const url = button.dataset.videoUrl
    if (!url) return
    
    // Abort any pending search requests since we're clearing results
    if (this._abortController) {
      this._abortController.abort()
    }
    
    this.urlFieldTarget.value = url
    this.resultsTarget.innerHTML = ''
    this.queryTarget.value = ''
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
}
