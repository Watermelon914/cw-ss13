#define to_world_log(message)                               world.log << (message)
#define debug_msg(message)                                  to_world(message) // A message define designed to be easily found and deleted
#define debug_log(message)                                  to_world_log(message)
#define sound_to(target, sound)                             target << (sound)
#define to_file(file_entry, source_var)                     file_entry << (source_var)
#define from_file(file_entry, target_var)                   file_entry >> (target_var)
#define close_browser(target, browser_name)                 target << browse(null, "window=[browser_name]")
#define show_image(target, image)                           target << (image)
#define send_rsc(target, args...)             				target << browse_rsc(##args)
#define open_link(target, url)                              target << link(url)

#define any2ref(x) ref(x)

#define CanInteract(user, state) (CanUseTopic(user, state) == STATUS_INTERACTIVE)

#define CanInteractWith(user, target, state) (target.CanUseTopic(user, state) == STATUS_INTERACTIVE)

#define CanPhysicallyInteract(user) CanInteract(user, GLOB.physical_state)

#define CanPhysicallyInteractWith(user, target) CanInteractWith(user, target, GLOB.physical_state)

#define QDEL_NULL_LIST(x) if(x) { for(var/y in x) { qdel(y) }}; if(x) {x.Cut(); x = null } // Second x check to handle items that LAZYREMOVE on qdel.

#define DROP_NULL(x) if(x) { x.dropInto(loc); x = null; }

#define ARGS_DEBUG log_debug("[__FILE__] - [__LINE__]") ; for(var/arg in args) { log_debug("\t[log_info_line(arg)]") }

// Helper macros to aid in optimizing lazy instantiation of lists.
// All of these are null-safe, you can use them without knowing if the list var is initialized yet

#define LAZYINITLIST(L) if (!L) { L = list(); }
#define UNSETEMPTY(L) if (L && !length(L)) L = null
///Like LAZYCOPY - copies an input list if the list has entries, If it doesn't the assigned list is nulled
#define LAZYLISTDUPLICATE(L) (L ? L.Copy() : null )
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
#define LAZYFIND(L, V) (L ? L.Find(V) : 0)
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;
#define LAZYLEN(L) length(L)
#define LAZYISIN(L, I) (L ? (I in L) : FALSE)
///Sets a list to null
#define LAZYNULL(L) L = null
#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null
#define QDEL_LAZYLIST(L) for(var/I in L) qdel(I); L = null;
//These methods don't null the list
#define LAZYCOPY(L) (L ? L.Copy() : list() ) //Use LAZYLISTDUPLICATE instead if you want it to null with no entries
#define LAZYCLEARLIST(L) if(L) L.Cut() // Consider LAZYNULL instead
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )

// Insert an object A into a sorted list using cmp_proc (/code/_helpers/cmp.dm) for comparison.
#define ADD_SORTED(list, A, cmp_proc) if(!list.len) {list.Add(A)} else {list.Insert(FindElementIndex(A, list, cmp_proc), A)}

//Currently used in SDQL2 stuff
#define send_output(target, msg, control) target << output(msg, control)
#define send_link(target, url) target << link(url)

// Spawns multiple objects of the same type
#define cast_new(type, num, args...) if((num) == 1) { new type(args) } else { for(var/i=0;i<(num),i++) { new type(args) } }

#define FLAGS_EQUALS(flag, flags) ((flag & (flags)) == (flags))

#define IS_DIAGONAL_DIR(dir) (dir & ~(NORTH|SOUTH))

#define REVERSE_DIR(dir) ((dir & (NORTH|SOUTH) ? ~dir & (NORTH|SOUTH) : 0) | (dir & (EAST|WEST) ? ~dir & (EAST|WEST) : 0))

#define GENERATE_DEBUG_ID "[rand(0, 9)][rand(0, 9)][rand(0, 9)][rand(0, 9)][pick(alphabet_lowercase)][pick(alphabet_lowercase)][pick(alphabet_lowercase)][pick(alphabet_lowercase)]"

#define RECT new /datum/shape/rectangle
#define QTREE new /datum/quadtree
#define SEARCH_QTREE(qtree, shape_range, flags) qtree.query_range(shape_range, null, flags)

#define HTML_FILE(contents) "<!DOCTYPE html><html><body>[contents]</body></html>"
