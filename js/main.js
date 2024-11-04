// Main JavaScript File for Schomburgk Digital Edition

// Wait for the DOM to load before executing scripts
document.addEventListener('DOMContentLoaded', function() {
  // Initialize entity filters
  initializeEntityFilters();

  // Initialize entity click events
  initializeEntityClickEvents();

  // Initialize Table of Contents scrolling
  initializeTOCScroll();

  // Placeholder for entity data
  let entityData = {};

  // Load entity data from external JSON files
  loadEntityData();

  // Function to initialize entity filters
  function initializeEntityFilters() {
    const filters = document.querySelectorAll('.filters input[type="checkbox"]');
    filters.forEach(function(checkbox) {
      checkbox.addEventListener('change', function() {
        const entityType = this.id.replace('filter-', '');
        const elements = document.querySelectorAll('.' + entityType + '-name');
        elements.forEach(function(el) {
          el.style.display = this.checked ? '' : 'none';
        }, this);
      });
    });
  }

  // Function to initialize entity click events
  function initializeEntityClickEvents() {
    const textContent = document.getElementById('text-content');
    textContent.addEventListener('click', function(event) {
      const target = event.target;
      if (target.matches('.person-name, .place-name, .flora-name, .fauna-name, .zoological-name')) {
        const entityId = target.getAttribute('data-id');
        const entityType = getEntityTypeFromClass(target.classList);
        const entityInfo = getEntityInfo(entityId, entityType);
        if (entityInfo) {
          showEntityInfoModal(entityInfo);
        } else {
          alert('No additional information available for this entity.');
        }
      }
    });
  }

  // Function to determine entity type from class list
  function getEntityTypeFromClass(classList) {
    if (classList.contains('person-name')) return 'persons';
    if (classList.contains('place-name')) return 'places';
    if (classList.contains('flora-name')) return 'flora';
    if (classList.contains('fauna-name')) return 'fauna';
    if (classList.contains('zoological-name')) return 'zoological';
    return null;
  }

  // Function to load entity data
  function loadEntityData() {
    // Load entity data from JSON files
    Promise.all([
      fetch('persons.json').then(response => response.json()),
      fetch('places.json').then(response => response.json()),
      fetch('flora.json').then(response => response.json()),
      fetch('fauna.json').then(response => response.json()),
      fetch('zoological.json').then(response => response.json())
    ]).then(([personsData, placesData, floraData, faunaData, zoologicalData]) => {
      entityData.persons = personsData.persons;
      entityData.places = placesData.places;
      entityData.flora = floraData.flora;
      entityData.fauna = faunaData.fauna;
      entityData.zoological = zoologicalData.zoological;
    }).catch(error => console.error('Error loading entity data:', error));
  }

  // Function to get entity information
  function getEntityInfo(id, type) {
    if (entityData[type] && entityData[type][id]) {
      return entityData[type][id];
    } else {
      return null;
    }
  }

  // Function to display entity information in a modal
  function showEntityInfoModal(info) {
    // Check if modal already exists
    let modalElement = document.getElementById('entityModal');
    if (modalElement) {
      modalElement.remove();
    }

    // Create modal content
    const modalContent = `
      <div class="modal fade" id="entityModal" tabindex="-1" aria-labelledby="entityModalLabel" aria-hidden="true">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title" id="entityModalLabel">${info.name}</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              ${info.description || '<p>No additional information available.</p>'}
            </div>
          </div>
        </div>
      </div>
    `;
    // Append modal to body
    document.body.insertAdjacentHTML('beforeend', modalContent);

    // Show modal using Bootstrap's modal plugin
    const entityModal = new bootstrap.Modal(document.getElementById('entityModal'));
    entityModal.show();

    // Remove modal from DOM after it's hidden
    document.getElementById('entityModal').addEventListener('hidden.bs.modal', function () {
      document.getElementById('entityModal').remove();
    });
  }

  // Function to initialize Table of Contents scrolling
  function initializeTOCScroll() {
    const tocLinks = document.querySelectorAll('.toc a');
    tocLinks.forEach(function(link) {
      link.addEventListener('click', function(event) {
        event.preventDefault();
        const targetId = this.getAttribute('href').substring(1);
        const targetElement = document.getElementById(targetId);
        if (targetElement) {
          targetElement.scrollIntoView({ behavior: 'smooth' });
        }
      });
    });
  }

});
