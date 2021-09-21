import Vue from "vue";
import App from "./App.vue";
import vuetify from "./plugins/vuetify";
import VueVideoPlayer from "vue-video-player";
import "video.js/dist/video-js.css";

Vue.config.productionTip = false;

Vue.use(VueVideoPlayer);

new Vue({
  vuetify,
  render: (h) => h(App),
}).$mount("#app");
