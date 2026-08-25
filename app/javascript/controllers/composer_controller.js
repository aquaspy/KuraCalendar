import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "choice",
    "eventBox", "eventForm", "eventHeading", "eventMethod", "eventDelete",
    "eventTitle", "eventBody", "eventAllDay", "eventStartsOn", "eventEndsOn",
    "eventTimes", "eventStartsAt", "eventEndsAt",
    "birthdayBox", "birthdayForm", "birthdayHeading", "birthdayMethod", "birthdayDelete",
    "birthdayName", "birthdayMonth", "birthdayDay", "birthdayYear", "birthdayBody"
  ]

  newEvent(event) {
    event?.preventDefault()
    this.closeChoice()
    this.fillEvent(event?.currentTarget)
    this.eventBoxTarget.showModal()
    this.eventTitleTarget.focus()
  }

  newBirthday(event) {
    event?.preventDefault()
    this.closeChoice()
    this.fillBirthday(event?.currentTarget)
    this.birthdayBoxTarget.showModal()
    this.birthdayNameTarget.focus()
  }

  openChoice(event) {
    event?.preventDefault()
    this.choiceTarget.showModal()
  }

  closeChoice() {
    if (this.hasChoiceTarget) this.choiceTarget.close()
  }

  closeEvent() { this.eventBoxTarget.close() }
  closeBirthday() { this.birthdayBoxTarget.close() }

  toggleTimes() {
    if (!this.hasEventTimesTarget || !this.hasEventAllDayTarget) return
    this.eventTimesTarget.hidden = this.eventAllDayTarget.checked
  }

  backdrop(event) {
    if (this.hasChoiceTarget && event.target === this.choiceTarget) this.closeChoice()
    if (event.target === this.eventBoxTarget) this.closeEvent()
    if (event.target === this.birthdayBoxTarget) this.closeBirthday()
  }

  fillEvent(trigger) {
    const data = trigger?.dataset || {}
    const id = data.id
    const form = this.eventFormTarget
    form.action = id ? `/events/${id}` : "/events"
    this.eventMethodTarget.value = id ? "patch" : "post"
    this.eventHeadingTarget.textContent = data.heading || ""
    this.eventTitleTarget.value = data.title || ""
    this.eventBodyTarget.value = data.body || ""
    this.eventStartsOnTarget.value = data.startsOn || data.date || ""
    this.eventEndsOnTarget.value = data.endsOn || data.startsOn || data.date || ""
    this.eventStartsAtTarget.value = data.startsAt || ""
    this.eventEndsAtTarget.value = data.endsAt || ""
    this.eventAllDayTarget.checked = data.allDay !== "false"
    this.toggleTimes()
    if (this.hasEventDeleteTarget) {
      this.eventDeleteTarget.hidden = !id
      this.eventDeleteTarget.dataset.url = id ? `/events/${id}` : ""
    }
  }

  fillBirthday(trigger) {
    const data = trigger?.dataset || {}
    const id = data.id
    const form = this.birthdayFormTarget
    form.action = id ? `/birthdays/${id}` : "/birthdays"
    this.birthdayMethodTarget.value = id ? "patch" : "post"
    this.birthdayHeadingTarget.textContent = data.heading || ""
    this.birthdayNameTarget.value = data.name || ""
    this.birthdayMonthTarget.value = data.month || ""
    this.birthdayDayTarget.value = data.day || ""
    this.birthdayYearTarget.value = data.year || ""
    this.birthdayBodyTarget.value = data.body || ""
    if (this.hasBirthdayDeleteTarget) {
      this.birthdayDeleteTarget.hidden = !id
      this.birthdayDeleteTarget.dataset.url = id ? `/birthdays/${id}` : ""
    }
  }
}
