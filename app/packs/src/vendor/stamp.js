import SHA1 from "src/vendor/sha1"

export default class Stamp {
  constructor(version, bits, date, resource, extension, rand, counter = 0) {
    this.version = version
    this.bits = bits
    this.date = date
    this.resource = resource
    this.extension = extension
    this.rand = rand
    this.counter = counter
  }
  
  static parse(string) {
    const args = string.split(":")
    return new Stamp(args[0], args[1], args[2], args[3], args[4], args[5], args[6])
  }
  
  toString() {
    return [this.version, this.bits, this.date, this.resource, this.extension, this.rand, this.counter].join(":")
  }
  
  // Trigger the given callback when the problem is solved.
  // In order to not freeze the page, setTimeout is called every 100ms to let some CPU to other tasks.
  work(callback) {
    this.startClock()
    const timer = performance.now()
    while (!this.check())
      if (this.counter++ && performance.now() - timer > 100)
        return setTimeout(this.work.bind(this), 0, callback)
    this.stopClock()
    callback(this)
  }
  
  check() {
    const array = SHA1(this.toString())
    return array[0] >> (160-this.bits) == 0
  }
  
  startClock() {
    this.startedAt || (this.startedAt = performance.now())
  }
  
  stopClock() {
    this.endedAt || (this.endedAt = performance.now())
    const duration = this.endedAt - this.startedAt
    const speed = Math.round(this.counter * 1000 / duration)
    console.debug("Hashcash " + this.toString() + " minted in " + duration + "ms (" + speed + " per seconds)")
  }
}