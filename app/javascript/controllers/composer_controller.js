import { Controller } from "@hotwired/stimulus"

const DRAFT_PREFIX = "kuracalendar_draft_"

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

  store(event) {
    const form = event.target.closest("form")
    if (!form) return
    const key = this.draftKey(form)
    if (!key) return
    const data = {}
    for (const el of form.elements) {
      if (!el.name || el.type === "hidden" || el.type === "submit" || el.type === "button") continue
      data[el.name] = el.type === "checkbox" ? el.checked : el.value
    }
    try { window.localStorage.setItem(key, JSON.stringify(data)) } catch {}
  }

  submitted(event) {
    if (event.detail?.success === false) return
    const form = event.target.closest ? event.target.closest("form") : null
    if (!form) return
    const key = this.draftKey(form)
    if (!key) return
    try { window.localStorage.removeItem(key) } catch {}
  }

  restoreInto(form) {
    const key = this.draftKey(form)
    if (!key) return
    let draft
    try {
      draft = JSON.parse(window.localStorage.getItem(key) || "null")
    } catch {
      return
    }
    if (!draft || typeof draft !== "object") return
    for (const el of form.elements) {
      if (!el.name || draft[el.name] === undefined) continue
      if (el.type === "hidden" || el.type === "submit" || el.type === "button") continue
      if (el.type === "checkbox") {
        el.checked = draft[el.name] === true
      } else if (typeof draft[el.name] === "string") {
        el.value = draft[el.name]
      }
    }
  }

  draftKey(form) {
    const match = form.action.match(/\/([a-z_]+)(?:\/(\d+))?(?:\?.*)?$/)
    return match ? `${DRAFT_PREFIX}${match[1]}_${match[2] || "new"}` : null
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
    this.restoreInto(form)
    if (!id && (data.date || data.startsOn)) {
      // The tapped day wins over a stale draft; the draft text is kept.
      this.eventStartsOnTarget.value = data.startsOn || data.date || ""
      this.eventEndsOnTarget.value = data.endsOn || data.startsOn || data.date || ""
    }
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
    this.restoreInto(form)
    if (!id && (data.month || data.day)) {
      // The tapped day wins over a stale draft; the draft text is kept.
      if (data.month) this.birthdayMonthTarget.value = data.month
      if (data.day) this.birthdayDayTarget.value = data.day
    }
    if (this.hasBirthdayDeleteTarget) {
      this.birthdayDeleteTarget.hidden = !id
      this.birthdayDeleteTarget.dataset.url = id ? `/birthdays/${id}` : ""
    }
  }
}
