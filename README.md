I develop a funding dapp with messages. You can sent donation-gifts via cross-chain by using axelar network.
I hard coded the message for this demo. I modified call-contract-with-token example.
For this demo:
You can sent tokens to the owner with your message.
I sent 1 aUsdc with message 'Buy a coffee from me!'
I stored all funding in the contract with messages. We can see who fund and what is the funding message with seeMessage function.
https://testnet.axelarscan.io/gmp/0x3a15c41591dd13293f0a4299e1ecd8effda59ab1473a6792180ea00dcdc34ecc:7

How it works:
First we have to approve the contract to sent our tokens.  
We encode our message. Because of message hard coded no need to pass as a parametre.
Then we call sendTokenWithMessage function with "Moonbeam" "Avalanche" 1
And that is it! We just sent 1 aUsdc token with Buy a coffee from me! message!

On contract:
I add string calldata message as a parameter of modified sentTomany func. (sendTokenWithMessage renamed)
I encode message and msg.sender to sent for executor
When its come to destination contract:
I encode the message and address data and store in the contract as mapping
I add seeMessage function to see who sent token and token messages
I also add a withdraw function so owner can withdraw their funds
