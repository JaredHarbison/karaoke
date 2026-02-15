import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    action: String,
    id: Number
  }
  
  async perform(event) {
    event.preventDefault()
    
    const action = this.actionValue
    const id = this.idValue
    
    try {
      const response = await fetch(`/${action}_song?id=${id}`, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      if (response.ok) {
        // Reload the page to show updated song list
        window.location.reload()
      } else {
        console.error('Action failed:', response.statusText)
      }
    } catch (error) {
      console.error('Error performing action:', error)
    }
  }
}
