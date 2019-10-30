---
title: "About"
date: 2019-07-14T19:14:50+02:00
author: "Ulisse Mini"
---

## Hi there

<p id="age">My name is Uli and I was born in 2004.</p>
I made it so I could write about the things I learn and hopefully someone else can benifit from it too.

## Contact

If you need to contact me, for any reason there are a few places.

I have a matrix account that I use for my main communication with friends, having moved away from discord because of its lack of end to end encryption
My matrix username is `valvate`

If you are lazy and use discord you can friend me `all hail ferris the crab#4334`, though it might be a while till I check my discord next.


If you're an old person then you can email me `ulisse.mini@gmail.com`, though it is unlikely that i'll see your message for a long time (if ever) because I'm a young hipster who only does instant messaging.

<script>
  "use strict";

  const birth_year = 2004;
  const birth_month = 9;

  const current_month = new Date().getMonth();
  const current_year = new Date().getFullYear();

  let my_age = current_year - birth_year;
  if (current_month < birth_month) {
    my_age--;
  }

  const age = document.getElementById("age");

  age.innerHTML = age.innerHTML.replace("I was born in 2004", "I'm " + my_age + " years old");
</script>
