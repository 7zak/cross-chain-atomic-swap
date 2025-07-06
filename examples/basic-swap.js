/**
 * Basic Atomic Swap Example
 * 
 * This example demonstrates how to perform a basic atomic swap
 * using the cross-chain atomic swap protocol.
 */

const crypto = require('crypto');
const { 
  StacksTestnet, 
  StacksMainnet,
  makeContractCall,
  broadcastTransaction,
  standardPrincipalCV,
  uintCV,
  bufferCV,
  stringAsciiCV
} = require('@stacks/transactions');

// Configuration
const NETWORK = new StacksTestnet(); // Use StacksMainnet() for production
const CONTRACT_ADDRESS = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'; // Replace with actual deployed contract
const CONTRACT_NAME = 'atomic-swap';

/**
 * Generate a secret and its hash for HTLC
 */
function generateSecret() {
  const secret = crypto.randomBytes(32);
  const hashLock = crypto.createHash('sha256').update(secret).digest();
  
  return {
    secret: secret.toString('hex'),
    hashLock: hashLock.toString('hex')
  };
}

/**
 * Initiate an atomic swap
 */
async function initiateSwap(senderKey, participant, amount, hashLock, timeLock) {
  console.log('Initiating atomic swap...');
  
  const txOptions = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'initiate-swap',
    functionArgs: [
      standardPrincipalCV(participant),
      uintCV(amount),
      bufferCV(Buffer.from(hashLock, 'hex')),
      uintCV(timeLock),
      stringAsciiCV('STX'),
      stringAsciiCV('BTC'),
      bufferCV(Buffer.from('1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12', 'hex')),
      uintCV(1), // single signature required
      uintCV(0)  // public swap
    ],
    senderKey,
    network: NETWORK,
    fee: 1000,
    nonce: 0 // You should fetch the actual nonce
  };

  try {
    const transaction = await makeContractCall(txOptions);
    const broadcastResponse = await broadcastTransaction(transaction, NETWORK);
    
    console.log('Swap initiated successfully!');
    console.log('Transaction ID:', broadcastResponse.txid);
    
    return broadcastResponse;
  } catch (error) {
    console.error('Error initiating swap:', error);
    throw error;
  }
}

/**
 * Claim an atomic swap
 */
async function claimSwap(senderKey, swapId, preimage) {
  console.log('Claiming atomic swap...');
  
  const txOptions = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'claim-swap',
    functionArgs: [
      bufferCV(Buffer.from(swapId, 'hex')),
      bufferCV(Buffer.from(preimage, 'hex'))
    ],
    senderKey,
    network: NETWORK,
    fee: 1000,
    nonce: 0 // You should fetch the actual nonce
  };

  try {
    const transaction = await makeContractCall(txOptions);
    const broadcastResponse = await broadcastTransaction(transaction, NETWORK);
    
    console.log('Swap claimed successfully!');
    console.log('Transaction ID:', broadcastResponse.txid);
    
    return broadcastResponse;
  } catch (error) {
    console.error('Error claiming swap:', error);
    throw error;
  }
}

/**
 * Refund an expired atomic swap
 */
async function refundSwap(senderKey, swapId) {
  console.log('Refunding atomic swap...');
  
  const txOptions = {
    contractAddress: CONTRACT_ADDRESS,
    contractName: CONTRACT_NAME,
    functionName: 'refund-swap',
    functionArgs: [
      bufferCV(Buffer.from(swapId, 'hex'))
    ],
    senderKey,
    network: NETWORK,
    fee: 1000,
    nonce: 0 // You should fetch the actual nonce
  };

  try {
    const transaction = await makeContractCall(txOptions);
    const broadcastResponse = await broadcastTransaction(transaction, NETWORK);
    
    console.log('Swap refunded successfully!');
    console.log('Transaction ID:', broadcastResponse.txid);
    
    return broadcastResponse;
  } catch (error) {
    console.error('Error refunding swap:', error);
    throw error;
  }
}

/**
 * Example usage
 */
async function example() {
  // Generate secret for HTLC
  const { secret, hashLock } = generateSecret();
  console.log('Generated secret:', secret);
  console.log('Hash lock:', hashLock);
  
  // Example addresses and keys (replace with real ones)
  const alicePrivateKey = 'your-alice-private-key-here';
  const bobAddress = 'ST2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7';
  
  try {
    // Alice initiates the swap
    const initiateResult = await initiateSwap(
      alicePrivateKey,
      bobAddress,
      1000000, // 1,000,000 microSTX
      hashLock,
      144 // 24 hours in blocks
    );
    
    console.log('Swap initiated:', initiateResult);
    
    // In a real scenario, Bob would now create a corresponding swap on Bitcoin
    // and Alice would claim Bob's Bitcoin using the secret
    
    // Then Bob would use the revealed secret to claim Alice's STX
    // const claimResult = await claimSwap(bobPrivateKey, swapId, secret);
    
  } catch (error) {
    console.error('Example failed:', error);
  }
}

// Export functions for use in other modules
module.exports = {
  generateSecret,
  initiateSwap,
  claimSwap,
  refundSwap,
  example
};

// Run example if this file is executed directly
if (require.main === module) {
  example();
}
