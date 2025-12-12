const { Storage } = require('@google-cloud/storage');

// This script configures CORS for Firebase Storage bucket
// Run with: node configure-cors.js

async function configureCors() {
  const storage = new Storage({
    projectId: 'payservices-7827a'
  });
  
  const bucketName = 'payservices-7827a.appspot.com';
  
  const corsConfiguration = [
    {
      origin: ['*'],
      method: ['GET', 'HEAD', 'PUT', 'POST', 'DELETE'],
      maxAgeSeconds: 3600,
      responseHeader: ['Content-Type', 'Access-Control-Allow-Origin']
    }
  ];
  
  try {
    await storage.bucket(bucketName).setCorsConfiguration(corsConfiguration);
    console.log(`CORS configuration set successfully for ${bucketName}`);
  } catch (error) {
    // Try alternative bucket name
    console.log('Trying alternative bucket name...');
    try {
      const altBucketName = 'payservices-7827a.firebasestorage.app';
      await storage.bucket(altBucketName).setCorsConfiguration(corsConfiguration);
      console.log(`CORS configuration set successfully for ${altBucketName}`);
    } catch (altError) {
      console.error('Error setting CORS:', altError.message);
      console.log('\nYou may need to authenticate first. Run:');
      console.log('1. Install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install');
      console.log('2. Run: gcloud auth application-default login');
      console.log('3. Then run this script again');
    }
  }
}

configureCors();
