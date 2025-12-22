## [  Autoplay policy](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Best_practices#autoplay_policy)

Browsers have started to implement an autoplay policy, which in general can be summed up as:

> "Create or resume context from inside a user gesture".

But what does that mean in practice? A user gesture has been interpreted to mean a user-initiated event, normally a `click` event. Browser vendors decided that Web Audio contexts should not be allowed to automatically play audio; they should instead be started by a user. This is because autoplaying audio can be really annoying and obtrusive. But how do we handle this?

When you create an audio context (either offline or online) it is created with a `state`, which can be `suspended`, `running`, or `closed`.

When working with an [`AudioContext`](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext), if you create the audio context from inside a `click` event the state should automatically be set to `running`. Here is an example of creating the context from inside a `click` event:

jsCopy

```
const button = document.querySelector("button");
button.addEventListener("click", () => {
  const audioCtx = new AudioContext();
  // Do something with the audio context
});
```

If however, you create the context outside of a user gesture, its state will be set to `suspended` and it will need to be started after user interaction. We can use the same click event example here, test for the state of the context and start it, if it is suspended, using the [`resume()`](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/resume) method.

jsCopy

```
const audioCtx = new AudioContext();
const button = document.querySelector("button");

button.addEventListener("click", () => {
  // check if context is in suspended state (autoplay policy)
  if (audioCtx.state === "suspended") {
    audioCtx.resume();
  }
});
```

You might instead be working with an [`OfflineAudioContext`](https://developer.mozilla.org/en-US/docs/Web/API/OfflineAudioContext), in which case you can resume the suspended audio context with the [`startRendering()`](https://developer.mozilla.org/en-US/docs/Web/API/OfflineAudioContext/startRendering) method.

## [User control](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Best_practices#user_control)

If your website or application contains sound, you should allow the user control over it, otherwise again, it will become annoying. This can be achieved by play/stop and volume/mute controls. The [Using the Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Using_Web_Audio_API) tutorial goes over how to do this.

Some controls you may find useful are: [`<button>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/button) elements for play/pause, [`<select>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/select) elements for selecting options like playback speed, [`<input type="checkbox">`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/checkbox) elements for toggling mute, and [`<input type="range">`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/range) elements for volume control and inputting other number values.

All the common considerations about form accessibility apply. When using [`<button>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/button) elements, you should ensure that they have a clear [label](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/label). This will help screen readers and other assistive technologies to understand the purpose of the button. If you have buttons that switch audio on and off, using the ARIA [`role="switch"`](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Reference/Roles/switch_role) attribute on them is a good option for signalling to assistive technology what the button's exact purpose is, and therefore making the app more accessible.

## [Setting AudioParam values](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Best_practices#setting_audioparam_values)

There are two ways to manipulate [`AudioNode`](https://developer.mozilla.org/en-US/docs/Web/API/AudioNode) values, which are themselves objects of type [`AudioParam`](https://developer.mozilla.org/en-US/docs/Web/API/AudioParam) interface. The first is to set the value directly via the property. So for instance if we want to change the `gain` value of a [`GainNode`](https://developer.mozilla.org/en-US/docs/Web/API/GainNode) we would do so thus:

jsCopy

```
gainNode.gain.value = 0.5;
```

This will set our volume to half. However, if you're using any of the `AudioParam`'s defined methods to set these values, they will take precedence over the above property setting. If for example, you want the `gain` value to be raised to 1 in 2 seconds time, you can do this:

jsCopy

```
gainNode.gain.setValueAtTime(1, audioCtx.currentTime + 2);
```

It will override the previous example (as it should), even if it were to come later in your code.

Bearing this in mind, if your website or application requires timing and scheduling, it's best to stick with the [`AudioParam`](https://developer.mozilla.org/en-US/docs/Web/API/AudioParam) methods for setting values. If you're sure it doesn't, setting it with the `value` property is fine.