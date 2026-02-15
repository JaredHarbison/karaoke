import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "results", "urlField", "embedPreview", "validationMessage"]
  
  async search(event) {
    event.preventDefault()
    
    const query = this.queryTarget.value.trim()
    if (!query) {
      this.resultsTarget.innerHTML = '<p>Please enter a search term</p>'
      return
    }
    
    this.resultsTarget.innerHTML = '<p>Searching YouTube...</p>'
    
    try {
      const response = await fetch(`/songs/youtube_search?query=${encodeURIComponent(query)}`, {
        headers: {
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      if (data.error) {
        this.resultsTarget.innerHTML = `<p class="error">Error: ${data.error}</p>`
        return
      }
      
      this.displayResults(data.items)
    } catch (error) {
      console.error('Search error:', error)
      this.resultsTarget.innerHTML = '<p class="error">Failed to search YouTube</p>'
    }
  }
  
  displayResults(items) {
    if (!items || items.length === 0) {
      this.resultsTarget.innerHTML = '<p>No results found</p>'
      return
    }
    
    const html = items.map(item => `
      <div class="youtube-result" data-url="${item.url}">
        <img src="${item.thumbnail}" alt="${item.title}" />
        <div class="youtube-result-info">
          <h4>${item.title}</h4>
          <p class="channel">${item.channel}</p>
          <button type="button" class="btn" data-action="click->youtube-search#selectVideo" data-url="${item.url}">
            Select This Video
          </button>
        </div>
      </div>
    `).join('')
    
    this.resultsTarget.innerHTML = html
  }
  
  async selectVideo(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.url
    
    this.urlFieldTarget.value = url
    this.resultsTarget.innerHTML = ''
    
    // Validate the selected video
    await this.validateVideo()
  }
  
  async validateVideo() {
    const url = this.urlFieldTarget.value.trim()
    
    if (!url) {
      this.clearValidation()
      return
    }
    
    this.validationMessageTarget.innerHTML = '<p>Validating video...</p>'
    
    try {
      const response = await fetch(`/songs/validate_video?url=${encodeURIComponent(url)}`, {
        headers: {
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      if (data.valid) {
        let message = '✓ Valid karaoke video'
        if (data.has_karaoke && data.has_lyrics) {
          message += ' (has karaoke & lyrics)'
        } else if (data.has_karaoke) {
          message += ' (has karaoke)'
        } else if (data.has_lyrics) {
          message += ' (has lyrics)'
        }
        
        this.validationMessageTarget.innerHTML = `<p class="success">${message}</p>`
        this.showEmbed(data.video_id)
      } else {
        this.validationMessageTarget.innerHTML = `
          <p class="warning">
            ⚠ This video may not be a karaoke video. 
            Please make sure "karaoke" or "lyrics" is in the title or description.
          </p>
        `
        this.showEmbed(data.video_id)
      }
    } catch (error) {
      console.error('Validation error:', error)
      this.validationMessageTarget.innerHTML = '<p class="error">Failed to validate video</p>'
    }
  }
  
  showEmbed(videoId) {
    if (!videoId) return
    
    this.embedPreviewTarget.innerHTML = `
      <div class="youtube-embed">
        <iframe 
          width="560" 
          height="315" 
          src="https://www.youtube.com/embed/${videoId}" 
          frameborder="0" 
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
          allowfullscreen>
        </iframe>
      </div>
    `
  }
  
  clearValidation() {
    if (this.hasValidationMessageTarget) {
      this.validationMessageTarget.innerHTML = ''
    }
    if (this.hasEmbedPreviewTarget) {
      this.embedPreviewTarget.innerHTML = ''
    }
  }
  
  // Trigger validation when URL field changes
  urlChanged() {
    // Debounce the validation
    clearTimeout(this.validationTimeout)
    this.validationTimeout = setTimeout(() => {
      this.validateVideo()
    }, 500)
  }
}
