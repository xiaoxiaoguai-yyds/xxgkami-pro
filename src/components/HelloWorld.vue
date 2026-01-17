<script setup>
import { ref } from 'vue'

defineProps({
  msg: String,
})

const count = ref(0)
</script>

<template>
  <div class="hello-world">
    <h1>{{ msg }}</h1>

    <div class="card">
      <button type="button" class="btn-primary" @click="count++">count is {{ count }}</button>
      <p>
        Edit
        <code>components/HelloWorld.vue</code> to test HMR
      </p>
    </div>

    <p>
      Check out
      <a href="https://vuejs.org/guide/quick-start.html#local" target="_blank"
        >create-vue</a
      >, the official Vue + Vite starter
    </p>
    <p>
      Learn more about IDE Support for Vue in the
      <a
        href="https://vuejs.org/guide/scaling-up/tooling.html#ide-support"
        target="_blank"
        >Vue Docs Scaling up Guide</a
      >.
    </p>
    <p class="read-the-docs">Click on the Vite and Vue logos to learn more</p>
  </div>
</template>

<style scoped>
.hello-world {
  text-align: center;
  color: #333;
}

.read-the-docs {
  color: #888;
}

.btn-primary {
  padding: 0.6em 1.2em;
  font-size: 1em;
  font-weight: 500;
  font-family: inherit;
  background-color: #646cff;
  border-radius: 6px;
  border: 1px solid transparent;
  cursor: pointer;
  color: white;
  transition: border-color 0.25s;
}

.btn-primary:hover {
  background-color: #535bf2;
}

.card {
  padding: 2em;
}
</style>
