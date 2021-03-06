describe 'number picker', ->
  fakePointerEvent =
    event:
      preventDefault: ->

  fakeEvent =
    preventDefault: ->

  clock = undefined
  beforeEach ->
    clock = sinon.useFakeTimers()

  afterEach ->
    clock.uninstall()

  it 'should have a default min of undefined', ->
    np = new hx.NumberPicker(hx.detached('div').node())
    should.not.exist(np.min())

  it 'should set and get the min option properly', ->
    np = new hx.NumberPicker(hx.detached('div').node(), { min: 20 })
    np.min().should.equal(20)
    np.min(0).min().should.equal(0)

  it 'should check the value when the min option is set', ->
    np = new hx.NumberPicker(hx.detached('div').node())
    np.value(-5).min(0).value().should.equal(0)

  it 'should have a default max of undefined', ->
    np = new hx.NumberPicker(hx.detached('div').node())
    should.not.exist(np.max())

  it 'should set and get the max option properly', ->
    np = new hx.NumberPicker(hx.detached('div').node(), { max: 20 })
    np.max().should.equal(20)
    np.max(0).max().should.equal(0)

  it 'should check the value when the max option is set', ->
    np = new hx.NumberPicker(hx.detached('div').node())
    np.value(5).max(0).value().should.equal(0)

  it 'should set and get the value properly', ->
    np = new hx.NumberPicker(hx.detached('div').node(), { value: 20 })
    np.value().should.equal(20)
    np.value(0).value().should.equal(0)

  it 'fluid api should return a selection with the correct component', ->
    npSel = hx.numberPicker()
    (npSel instanceof hx.Selection).should.equal(true)
    (npSel.component() instanceof hx.NumberPicker).should.equal(true)

  it 'typing should set the value correctly', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node())
    input = sel.select('input')
    input.value(10)
    np.value().should.equal(0)
    testHelpers.fakeNodeEvent(input.node(), 'blur')(fakeEvent)
    np.value().should.equal(10)

  it 'typing should adhere to max', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node(), {max: 5})
    input = sel.select('input')
    input.value(10)
    np.value().should.equal(0)
    testHelpers.fakeNodeEvent(input.node(), 'blur')(fakeEvent)
    np.value().should.equal(5)

  it 'typing should adhere to min', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node(), {min: -5})
    input = sel.select('input')
    input.value(-10)
    np.value().should.equal(0)
    testHelpers.fakeNodeEvent(input.node(), 'blur')(fakeEvent)
    np.value().should.equal(-5)

  it 'should initialise with correct disabled state', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node(), {disabled: true})
    np.disabled().should.equal(true)
    sel.select('button').map (btn) -> btn.attr('disabled').should.equal 'disabled'

  it 'disabled: should enable a disabled number picker', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node(), {disabled: true})
    np.disabled().should.equal(true)
    sel.select('button').map (btn) -> btn.attr('disabled').should.equal 'disabled'
    np.disabled(false).should.equal(np)
    np.disabled().should.equal(false)
    sel.select('button').map (btn) -> should.not.exist(btn.attr('disabled'))

  it 'disabled: should disable the number picker', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node())
    np.disabled().should.equal(false)
    sel.select('button').map (btn) -> should.not.exist(btn.attr('disabled'))
    np.disabled(true).should.equal(np)
    np.disabled().should.equal(true)
    sel.select('button').map (btn) -> btn.attr('disabled').should.equal 'disabled'

  it 'value: should deal with screenValue correctly', ->
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node())
    np.value(0, 'zero')
    np.value().should.equal(0)
    sel.select('input').value().should.equal('zero')
    sel.select('input').attr('readonly').should.equal('readonly')

  it 'should not call value when bluring from an input with a screenValue', ->
    change = chai.spy()
    sel = hx.detached('div')
    np = new hx.NumberPicker(sel.node())
    np.on('input-change', change)
    np.value(0, 'zero')
    np.value().should.equal(0)
    sel.select('input').value().should.equal('zero')
    sel.select('input').attr('readonly').should.equal('readonly')

    chai.spy.on(np, 'value')
    testHelpers.fakeNodeEvent(np.selectInput.node(), 'blur')(fakeEvent)
    np.value.should.not.have.been.called()
    change.should.not.have.been.called()

  describe 'events', ->
    it 'change: should emit whenever the value is changed', ->
      change = chai.spy()

      sel = hx.detached('div')
      np = new hx.NumberPicker(sel.node())
      np.on('change', change)

      np.value(1).should.equal(np)
      change.should.have.been.called.with({ value: 1 })
      change.reset()
      np.increment().should.equal(np)
      change.should.have.been.called.with({ value: 2 })
      change.reset()
      np.decrement().should.equal(np)
      change.should.have.been.called.with({ value: 1 })
      change.reset()
      np.decrement().should.equal(np)
      change.should.have.been.called.with({ value: 0 })

    it 'change: should emit whenever the value is changed by the min/max function', ->
      change = chai.spy()

      sel = hx.detached('div')
      np = new hx.NumberPicker(sel.node(), {value: 0})
      np.debug = true
      np.on('change', change)

      np.min(5).should.equal(np)
      np.value().should.equal(5)
      change.should.have.been.called.with({ value: 5 })
      change.reset()
      np.min(0).should.equal(np)
      np.value().should.equal(5)
      change.should.not.have.been.called()
      change.reset()
      np.max(0).should.equal(np)
      np.value().should.equal(0)
      change.should.have.been.called.with({ value: 0 })
      change.reset()
      np.max(5).should.equal(np)
      np.value().should.equal(0)
      change.should.not.have.been.called()

    it 'input-change: should emit whenever the input text is is updated ', ->
      change = chai.spy()

      sel = hx.detached('div')
      np = new hx.NumberPicker(sel.node())
      np.on('input-change', change)

      np.value().should.equal(0)
      np.selectInput.value(5)
      change.should.not.have.been.called()
      testHelpers.fakeNodeEvent(np.selectInput.node(), 'blur')(fakeEvent)
      change.should.have.been.called.with({value: 5})

    it 'decrement: should emit when the user decrements', ->
      change = chai.spy()

      sel = hx.detached('div')
      np = new hx.NumberPicker(sel.node())
      np.on('decrement', change)

      buttonNode = sel.select('.hx-number-picker-decrement').node()

      change.should.not.have.been.called()
      testHelpers.fakeNodeEvent(buttonNode, 'pointerdown')(fakePointerEvent)
      clock.tick(100)
      testHelpers.fakeNodeEvent(buttonNode, 'pointerup')(fakePointerEvent)
      change.should.have.been.called.once()
      np.value().should.equal(-1)

    it 'increment: should emit when the user increments', ->
      change = chai.spy()

      sel = hx.detached('div')
      np = new hx.NumberPicker(sel.node())
      np.on('increment', change)

      buttonNode = sel.select('.hx-number-picker-increment').node()

      change.should.not.have.been.called()
      testHelpers.fakeNodeEvent(buttonNode, 'pointerdown')(fakePointerEvent)
      clock.tick(100)
      testHelpers.fakeNodeEvent(buttonNode, 'pointerup')(fakePointerEvent)
      change.should.have.been.called.once()
      np.value().should.equal(1)

  testButton = (method, selector, multiplier) ->
    describe method, ->
      it "#{method}: should increment the number picker", ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node())
        np.value().should.equal(0)
        np[method]().should.equal(np)
        np.value().should.equal(1 * multiplier)

      it "#{method}: should adhere to min/max values", ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node(), {min: -1, max: 1})
        np.value().should.equal(0)
        np[method]().should.equal(np)
        np.value().should.equal(1 * multiplier)
        np[method]().should.equal(np)
        np.value().should.equal(1 * multiplier)

      it "#{method}: should disable the button when at the min/max value", ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node(), {min: -5, max: 5, value: multiplier * 5})
        sel.select(".hx-number-picker-#{method}").attr('disabled').should.equal('disabled')
        np.value(0).should.equal(np)
        should.not.exist(sel.select(".hx-number-picker-#{method}").attr('disabled'))

      it 'button: should increment correctly when clicking the button', ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node())
        np.value().should.equal(0)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerdown')(fakePointerEvent)
        clock.tick(100)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerup')(fakePointerEvent)
        np.value().should.equal(1 * multiplier)

      it 'button: should not increment when the button is disabled', ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node())
        np.disabled(true)
        np.value().should.equal(0)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerdown')(fakePointerEvent)
        clock.tick(100)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerup')(fakePointerEvent)
        np.value().should.equal(0)

      it 'button: should increment when holding the button', ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node())
        np.value().should.equal(0)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerdown')(fakePointerEvent)
        clock.tick(500)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerup')(fakePointerEvent)
        np.value().should.equal(6 * multiplier)

      it 'button: should increment correctly when clicking the button and incrementOnHold is disabled', ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node(), {incrementOnHold: false})
        np.value().should.equal(0)
        testHelpers.fakeNodeEvent(sel.select(selector).node())(fakePointerEvent)
        np.value().should.equal(1 * multiplier)

      it 'button: should stop incrementing when the pointer leaves the button', ->
        sel = hx.detached('div')
        np = new hx.NumberPicker(sel.node())
        np.value().should.equal(0)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerdown')(fakePointerEvent)
        clock.tick(500)
        testHelpers.fakeNodeEvent(sel.select(selector).node(), 'pointerleave')(fakePointerEvent)
        clock.tick(500)
        np.value().should.equal(6 * multiplier)

  testButton 'increment', '.hx-number-picker-increment', 1
  testButton 'decrement', '.hx-number-picker-decrement', -1
