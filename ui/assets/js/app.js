document.addEventListener('DOMContentLoaded', async function() {
  var priceperword = 2
  var baseprice = 0
  var notification = {
    messagemode: "anon",
    content: ""
  }
  var lettercount = document.getElementById('lettercount');
  var textarea = document.querySelector('textarea');
  var pricetag = document.querySelector('.interface-left-price-left-text h1')

  textarea.addEventListener('input', function() {
    lettercount.textContent = textarea.value.length;
    pricetag.textContent = Convertmoney(textarea.value.length * priceperword);
    document.querySelector(".interface-left-price-right-text h1").innerHTML = Convertmoney(textarea.value.length * priceperword + baseprice);
  });

  var messagemode = document.querySelectorAll('.interface-left-type-left-right h1')

  messagemode.forEach(function(element) {
    element.addEventListener('click', function() {
      messagemode.forEach(function(element) {
        element.classList.remove('active');
        element.classList.add('unactive');
      });

      this.classList.remove('unactive');
      this.classList.add('active');
      notification.messagemode = this.id;
    });
  })

  async function AppendHistory(data) {
    document.querySelector('.interface-right-scrollcontainer').innerHTML = "";
    data.reverse();
    data = data.slice(Math.max(data.length - 10, 0))
    data.forEach(function(message) {
    const html = `
        <div class="interface-right-scrollcontainer-tile">
        <div class="interface-right-scrollcontainer-tile-main">
            <div class="interface-right-scrollcontainer-tile-main-side"></div>
            <h1>${message.content}</h1>
        </div>
        <div class="interface-right-scrollcontainer-tile-main-user">
            <div class="interface-right-scrollcontainer-tile-main-user-top">
                <div class="interface-right-scrollcontainer-tile-userinfo-tile" style="width: 5.83vmin;">
                    <div class="interface-right-scrollcontainer-tile-userinfo-tile-left">
                        <img src="./assets/img/phone.svg" draggable="false">
                    </div>
                    <div class="interface-right-scrollcontainer-tile-userinfo-tile-right" style="width: 60%;">
                        <h1>${message.phone}</h1>
                    </div>
                </div>
                <div class="interface-right-scrollcontainer-tile-userinfo-tile" style="width: 12.31vmin;">
                    <div class="interface-right-scrollcontainer-tile-userinfo-tile-left">
                        <img src="./assets/img/clock.svg" draggable="false">
                    </div>
                    <div class="interface-right-scrollcontainer-tile-userinfo-tile-right" style="width: 81%;">
                        <h1>${message.time} / ${message.date}</h1>
                    </div>
                </div>
            </div>
            <div class="interface-right-scrollcontainer-tile-userinfo-tile" style="width: 18.52vmin;">
                <div class="interface-right-scrollcontainer-tile-userinfo-tile-left">
                    <img src="./assets/img/user.svg" draggable="false">
                </div>
                <div class="interface-right-scrollcontainer-tile-userinfo-tile-right" style="width: 87%;">
                    <h1>${message.name}</h1>
                </div>
            </div>
        </div>
    </div>
    `

    document.querySelector('.interface-right-scrollcontainer').insertAdjacentHTML('beforeend', html);
    })
  }

  function Convertmoney(money) {
    var money = '$' + money.toString().split('').reverse().join('').replace(/(\d{3})(?=\d)/g, '$1,').split('').reverse().join('');
    return money;
  }

  async function SetPlayerData(data) {
    document.querySelector('.interface-left-head-right-name h1').textContent = data.name;
    document.querySelector('.interface-left-head-right-name p').textContent = Convertmoney(data.money);
    document.querySelector('.interface-left-head-right-pfp img').src = data.pfp;
  }

  document.querySelector('.interface-left-head-right-close').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      body: JSON.stringify({}),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      }
    })
  });

  document.querySelector('.cancel').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      body: JSON.stringify({}),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      }
    })
  });

  document.querySelector('.send').addEventListener('click', function() {
    if (textarea.value.length > 0) {
      notification.content = textarea.value;
      // remove useless spaces and newlines from the message
      notification.content = notification.content.replace(/\s+/g, ' ').trim();
      fetch(`https://${GetParentResourceName()}/send`, {
        method: 'POST',
        body: JSON.stringify(notification),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        }
      })
    }
  });

  function SetMaxlenght(maxlenght) {	
    document.querySelector("textarea").setAttribute("maxlength", maxlenght);
    document.querySelector("#maxwords").innerHTML = maxlenght
  }

  function SetBasePrice(price) {
    document.querySelector(".interface-left-price-right-text h1").innerHTML = Convertmoney(price);
    baseprice = price;
  }

  function Close() {
    document.querySelector('body').style.display = 'none';
  }

  function Open() {
    document.querySelector('body').style.display = 'flex';
  }

  window.addEventListener('message', function(event) {
    var data = event.data;

    if (data.type == "open") {
      SetPlayerData(data.plrdata);
      AppendHistory(data.messages);
      SetMaxlenght(data.maxletters);
      SetBasePrice(data.baseprice);
      priceperword = data.priceperword;
      Open();
    } else if (data.type == "close") {
      Close();
    }
  });
});