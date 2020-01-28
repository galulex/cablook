<script>
  export let trips = {}
</script>

<ol>
  {#each Object.values(trips) as trip, i}
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
