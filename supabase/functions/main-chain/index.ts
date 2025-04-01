import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
);

async function invoker() {
  const response = await supabaseClient.functions.invoke('redis-counter')
  console.log(response)
}

Deno.serve(async (req) => {
  addEventListener('beforeunload', (ev) => {
    console.log('Function will be shutdown due to', ev.detail?.reason)
  })

  for (let index = 0; index < 100; index++) {
    EdgeRuntime.waitUntil(invoker())
  }
  
  return new Response('ok')
});