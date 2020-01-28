<script>
  export let trips = {}
</script>

<section>
  <ol id='proposals'>
    {#each Object.values(trips).filter(trip => { return trip.status === 0 }) as trip, i}
      <li>
        <ul>
          {#each trip.stops as stop, i}
            <li>{stop}</li>
          {/each}
        </ul>
        <blockquote>{trip.comment}</blockquote>
        <a class='button' disabled={trip.no_call} href={`tel:${trip.user_number}`}>✆</a>
        <br/>
        <button type='button'>GO</button>
      </li>
    {/each}
  </ol>
  <ol id='current'>
    {#each Object.values(trips).filter(trip => { return trip.driver_id === parseInt(localStorage.id) }) as trip, i}
      <li>
        <ul>
          {#each trip.stops as stop, i}
            <li>{stop}</li>
          {/each}
        </ul>
        <blockquote>{trip.comment}</blockquote>
        <a class='button' disabled={trip.no_call} href={`tel:${trip.user_number}`}>✆</a>
        <br/>
        <button type='button'>Arrived</button>
      </li>
    {/each}
  </ol>
</section>
