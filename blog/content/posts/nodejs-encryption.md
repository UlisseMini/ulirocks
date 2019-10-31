---
title: "Nodejs Encryption"
date: 2019-10-30T21:39:20-04:00
draft: false
toc: false
images:
tags: 
  - untagged
---

# I hate javascript
But I'm using it to write a discord bot, for a few reasons (mostly the awesome [discordjs](https://discord.js.org) api) I desided it was the easiest way to get my friends into programming via writing discord bots.


So, I thought it would be cool to add encryption-decryption functionality to my bot.

I'm a perfectionist so I wanted nothing less then `aes256-gcm` + a good KDF (I picked scrypt), Since I'm quite minimal, I desided to use the [crypto](https://nodejs.org/api/crypto.html) package provided by node Instead of grabbing an insecure unmaintained package from npm.

Here Is the version I came up with after some iteration.

```javascript
function encrypt(text, passphrase) {
  const salt = crypto.randomBytes(32)
  const key = crypto.scryptSync(passphrase, salt, 32)

  const iv = crypto.randomBytes(16)
  const encrypter = crypto.createCipheriv('aes-256-gcm', key, iv)

  let encrypted = encrypter.update(text)
  encrypted = Buffer.concat([encrypted, encrypter.final()])

  return Buffer.concat([iv, encrypter.getAuthTag(), salt, encrypted]).toString('base64')
}

function decrypt(text, passphrase) {
  // First we need to get iv, authtag, salt, ciphertext from base64.
  text = Buffer.from(text, 'base64')

  const iv = text.slice(0, 16)
  const tag = text.slice(16, 32)
  const salt = text.slice(32, 64)
  const ciphertext = text.slice(64, text.length)

  // Now we preform the decryption.
  const key = crypto.scryptSync(passphrase, salt, 32)
  const decrypter = crypto.createDecipheriv('aes-256-gcm', key, iv)
  decrypter.setAuthTag(tag)
  let decrypted = decrypter.update(ciphertext)
  decrypted += decrypter.final()

  return decrypted
}

```

A key thing to notice, Is the encoding back-and forth from a single base64 string, for the usecase of a discord bot I did not want to return output along the lines of

```json
{
  "iv": "xyz",
  "salt": "xyz",
  "ciphertext": "xyz",
  "tag": "xyz"
}
```

Because that would scare non-technical users, and be harder to copy-paste (also people would feel like its less encrypted, even though its not.

In the end it works quite well, here is a screenshot of the bot encrypting-decrypting text.
![Screenshot of discord bot](/img/encrypt-bot.png)

Thanks for reading and I hope you learned something :)
