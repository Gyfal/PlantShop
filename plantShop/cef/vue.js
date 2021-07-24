let newSteps = [
  { title: 'Кактус', text: 1000, status: false, message: "Недостаточно средств" },
  { title: 'Ель', text: 2000, status: false, message: "Недостаточно средств" },
  { title: 'Береза', text: 3000, status: false, message: "Недостаточно средств" },
]

Vue.component("modal", {
  template: "#modal-template"
}); 

var vue = new Vue({
  el: '#app',
  data() {
    return {
      activeIndex: -1,
      focused: false,
      money: 5000,
      select: -1,
      main: false,
      isActive: true,
      steps: newSteps,
      showModal: false,
      buyed: [
        { select: -1 }
      ],
      picture: [
        { img: "img/Cactus.png" },
        { img: "img/elka.png" },
        { img: "img/Bereza.png" },
      ],
    }
  },
  methods: {
    closed() {
      console.log("Try closed")
      mta.triggerEvent("plantShop:closedGUI");
    },
    refresher() {
      //  mta.triggerEvent("plantShop:refresh");
    },
    mouseOver: function () {
       mta.triggerEvent("plantShop:refresh");
    },
    persist() {
      localStorage.steps = newSteps;
    },
    updater() {
      return this.steps[0];
    },
    onFocus() {
      this.focused = true
    },
    onBlur() {
      this.activeIndex = -1
    },
    buy(id) {
      console.log("buy", this.activeIndex)
      if (this.money >= this.steps[ this.activeIndex].text) {
        // this.showModal = true;  
        mta.triggerEvent('plantShop:guiBuy', this.activeIndex + 1)
        
      } else {
        this.money = 0;
      }
      
    },
    prev() {
      if (this.activeIndex !== 0) {
        this.activeIndex--
      }
    },
    reset() {
      this.activeIndex = 0
      this.isActive = true
    },
    nextOfFinish() {
      if (this.activeIndex !== this.steps.length - 1) {
        this.activeIndex++
      } else {
        this.isActive = false
      }
    },
    setActive(idx) {
      select = idx;
      this.activeIndex = idx
    },
  },
  computed: {
    set() {
      return this.activeIndex
    },
    activeStep() {
      return this.steps[this.activeIndex]
    },
    prevDisabled() {
      return this.activeIndex === 0
    },
    isLastStep() {
      return this.activeIndex === this.steps.length - 1
    }
  }
})


function updateInfo(semena, money) {
  vue.$data.money = money;
  const obj = JSON.parse(semena);
  for (let index = 1; index <= 3; index++) {
    vue.$data.steps[index - 1].status = obj[0][index]
  }  
}

function setParam(table) {
  console.log("HERE 1231")
  if (table !== undefined) {
    vue.$data.steps = JSON.parse(table);
  }
  return "undefined!!!!"
}


function setStatus(id, status) {
  if (id !== undefined) {
    vue.$data.steps[id].status = status;
  }
}

function setTitle(id, title) {
  if (id !== undefined) {
    vue.$data.steps[id].title = title;
  }
}

function setPrice(id, price) {
  if (id !== undefined) {
    vue.$data.steps[id].text = price;
  }
}


function onDOMContentLoaded() {
  mta.triggerEvent("plantShop:guiLoad");
}


document.addEventListener("DOMContentLoaded", onDOMContentLoaded);